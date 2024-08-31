"""Utility functions first."""

import numpy as np
from numba import njit
from typing import Union
from numba.typed import List

ONE_OV_SQRT_2PI = 0.3989422804014327  # 1.0/sqrt(2.0*pi)
ONE_OV_SQRT_2 = 0.7071067811865475  # 1.0/sqrt(2.0)
SQRT_2 = 1.41421356237  # = sqrt(2)
TWO_OV_PI = 0.63661977236  # = 2.0/pi


@njit(cache=False, fastmath=True)
def erfcc(x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
    """
    Complementary error function.

    using algorithm from Press, William H. (2002), 2nd ed
    Numerical Recipes in C++: The Art of Scientific Computing. Cambridge University Press. p. 226.
    maximal error of 1.2×10−7 for any real argument
    """
    z = np.abs(x)
    t = 1.0 / (1.0 + 0.5 * z)
    r = t * np.exp(
        -z * z
        - 1.26551223
        + t
        * (
            1.00002368
            + t
            * (
                0.37409196
                + t
                * (
                    0.09678418
                    + t
                    * (
                        -0.18628806
                        + t
                        * (
                            0.27886807
                            + t
                            * (
                                -1.13520398
                                + t
                                * (
                                    1.48851587
                                    + t * (-0.82215223 + t * 0.17087277)
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    fcc = np.where(np.greater(x, 0.0), r, 2.0 - r)
    return fcc


@njit(cache=False, fastmath=True)
def ncdf(x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
    return 1.0 - 0.5 * erfcc(ONE_OV_SQRT_2 * x)


@njit(cache=False, fastmath=True)
def npdf(x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
    return ONE_OV_SQRT_2PI * np.exp(-0.5 * np.square(x))


@njit(cache=False, fastmath=True)
def inv_erf(x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
    """
    Inverse of erf function.

    x in (0, 1)
    See Eq 7 in A handy approximation for the error function and its inverse, Sergei Winitzki
    https://www.academia.edu/download/35916780/erf-approx.pdf
    largest relative error is about 1.3 · 10−4
    """
    a = 0.147
    const = TWO_OV_PI / a
    log_one_minus_x2 = np.log(1.0 - np.square(x))
    invf = np.sqrt(
        -const
        - 0.5 * log_one_minus_x2
        + np.sqrt(np.square(const + log_one_minus_x2) - log_one_minus_x2 / a)
    )
    return invf


@njit(cache=False, fastmath=True)
def ncdf_inv(x: Union[float, np.ndarray]) -> Union[float, np.ndarray]:
    """
    Inverse of the normal cdf.

    x in (0, 1)
    """
    return SQRT_2 * inv_erf(2.0 * x - 1.0)


@njit
def is_intrinsic(ttm: float, vol: float) -> bool:
    if ttm <= 0.0 or vol <= 0.0 or np.isnan(vol):
        return True
    else:
        return False


"""
prices
"""


@njit
def bsm_price(
    forward: float,
    strike: float,
    ttm: float,
    vol: float,
    optype: str = "C",
    discfactor: float = 1.0,
) -> float:
    """
    Ttm: time-to-maturity.

    bsm pricer for forward
    forward = spot * exp((r-q)*ttm)
    """
    if is_intrinsic(ttm=ttm, vol=vol):
        if optype == "C" or optype == "IC":
            price = np.maximum(forward - strike, 0.0)
        elif optype == "P" or optype == "IP":
            price = np.maximum(strike - forward, 0.0)
        else:
            raise NotImplementedError(f"Option type {optype} not implemented")
    else:
        s_ttm = vol * np.sqrt(ttm)
        d1 = (np.log(forward / strike) + 0.5 * s_ttm * s_ttm) / s_ttm
        d2 = d1 - s_ttm
        if optype == "C" or optype == "IC":
            price = discfactor * (forward * ncdf(d1) - strike * ncdf(d2))
        elif optype == "P" or optype == "IP":
            price = -discfactor * (forward * ncdf(-d1) - strike * ncdf(-d2))
        else:
            raise NotImplementedError(f"Option type {optype} not implemented")
    return price


bsm_price_vector = np.vectorize(
    bsm_price, doc="Vectorized `bsm_vanilla_price` function"
)


@njit
def bsm_slice_prices(
    ttm: float,
    forward: float,
    strikes: np.ndarray,
    vols: np.ndarray,
    optypes: np.ndarray,
    discfactor: float = 1.0,
) -> np.ndarray:
    """Vectorised bsm deltas for array of aligned strikes, vols, & optypes."""

    def f(strike: float, vol: float, optype: str) -> float:
        return bsm_price(
            forward=forward,
            strike=strike,
            ttm=ttm,
            vol=vol,
            optype=optype,
            discfactor=discfactor,
        )

    bsm_prices = np.zeros_like(strikes)
    for idx, (strike, vol, optype) in enumerate(zip(strikes, vols, optypes)):
        bsm_prices[idx] = f(strike, vol, optype)
    return bsm_prices


@njit
def bsm_forward_grid_prices(
    ttm: float,
    forwards: np.ndarray,
    strike: float,
    vol: float,
    optype: str,
    discfactor: float = 1.0,
) -> np.ndarray:
    def f(forward: float) -> float:
        return bsm_price(
            forward=forward,
            ttm=ttm,
            vol=vol,
            strike=strike,
            optype=optype,
            discfactor=discfactor,
        )

    bsm_prices = np.zeros_like(forwards)
    for idx, forward in enumerate(forwards):
        bsm_prices[idx] = f(forward)
    return bsm_prices


"""
deltas
"""


@njit
def bsm_delta(
    ttm: float,
    forward: float,
    strike: float,
    vol: float,
    optype: str,
    discfactor: float = 1.0,
) -> float:
    """BSM deltas for strikes & vols."""
    if is_intrinsic(ttm=ttm, vol=vol):
        if optype == "C" or optype == "IC":
            bsm_deltas = 1.0 if forward >= strike else 0.0
        elif optype == "P" or optype == "IP":
            bsm_deltas = -1.0 if forward <= strike else 0.0
        else:
            raise NotImplementedError(f"Option type {optype}")
    else:
        s_ttm = vol * np.sqrt(ttm)
        d1 = np.log(forward / strike) / s_ttm + 0.5 * s_ttm
        if optype == "C":
            d1_sign = 1.0
        elif optype == "P":
            d1_sign = -1.0
        else:
            d1_sign = 0.0
        bsm_deltas = discfactor * d1_sign * ncdf(d1_sign * d1)
    return bsm_deltas


bsm_delta_vector = np.vectorize(bsm_delta, doc="Vectorized `bsm_delta`")


@njit
def bsm_slice_deltas(
    ttm: float,
    forward: float,
    strikes: np.ndarray,
    vols: np.ndarray,
    optypes: np.ndarray,
) -> Union[float, np.ndarray]:
    """BSM deltas for strikes & vols."""

    def f(strike: float, vol: float, optype: str) -> float:
        return bsm_delta(
            forward=forward, ttm=ttm, strike=strike, vol=vol, optype=optype
        )

    bsm_deltas = np.zeros_like(strikes)
    for idx, (strike, vol, optype) in enumerate(zip(strikes, vols, optypes)):
        bsm_deltas[idx] = f(strike, vol, optype)
    return bsm_deltas


@njit
def bsm_deltas_ttms(
    ttms: np.ndarray,
    forwards: np.ndarray,
    strikes_ttms: List[np.ndarray],
    vols_ttms: List[np.ndarray],
    types_ttms: List[np.ndarray],
) -> List[np.ndarray]:
    """Vectorized bsm deltas for an array of aligned strikes, vols, & optypes."""
    deltas_ttms = List()
    for ttm, forward, vols_ttm, strikes_ttm, optypes_ttm in zip(
        ttms, forwards, vols_ttms, strikes_ttms, types_ttms
    ):
        deltas_ttms.append(
            bsm_slice_deltas(
                ttm=ttm,
                forward=forward,
                strikes=strikes_ttm,
                vols=vols_ttm,
                optypes=optypes_ttm,
            )
        )
    return deltas_ttms


@njit
def bsm_grid_deltas(
    ttm: float,
    forwards: np.ndarray,
    strike: float,
    vol: float,
    optype: str,
    discfactor: float = 1.0,
) -> np.ndarray:
    """Vectorised bsm deltas for array of forwards grid."""

    def f(forward: float) -> float:
        return bsm_delta(
            forward=forward,
            ttm=ttm,
            vol=vol,
            strike=strike,
            optype=optype,
            discfactor=discfactor,
        )

    bsm_deltas = np.zeros_like(forwards)
    for idx, forward in enumerate(forwards):
        bsm_deltas[idx] = f(forward)
    return bsm_deltas


def bsm_strike_from_delta(
    ttm: float, forward: float, delta: float, vol: float
) -> Union[float, np.ndarray]:
    """Bsm deltas for strikes & vols."""
    inv_delta = ncdf_inv(delta) if delta > 0.0 else -ncdf_inv(-delta)
    sT = vol * np.sqrt(ttm)
    strike = forward * np.exp(-sT * (inv_delta - 0.5 * sT))
    return strike


"""
Vega
"""


@njit
def bsm_vega(ttm: float, forward: float, strike: float, vol: float) -> float:
    """Vectorised bsm vegas for array of aligned strikes, vols, & optypes."""
    if is_intrinsic(ttm=ttm, vol=vol):
        vega = 0.0
    else:
        sT = vol * np.sqrt(ttm)
        d1 = np.log(forward / strike) / sT + 0.5 * sT
        vega = forward * ncdf(d1) * np.sqrt(ttm)
    return vega


bsm_vega_vector = np.vectorize(bsm_vega, doc="Vectorized `bsm_vega`")


@njit
def compute_bsm_slice_vegas(
    ttm: float,
    forward: float,
    strikes: np.ndarray,
    vols: np.ndarray,
    optypes: np.ndarray = None,
) -> np.ndarray:
    """Vectorized bsm vegas for array of aligned strikes, vols, & optypes."""
    sT = vols * np.sqrt(ttm)
    d1 = np.log(forward / strikes) / sT + 0.5 * sT
    vegas = forward * npdf(d1) * np.sqrt(ttm)
    return vegas


@njit
def compute_bsm_vegas_ttms(
    ttms: np.ndarray,
    forwards: np.ndarray,
    strikes_ttms: List[np.ndarray],
    vols_ttms: List[np.ndarray],
    types_ttms: List[np.ndarray],
) -> List[np.ndarray]:
    """Vectorized bsm vegas for an array of aligned strikes, vols, & optypes."""
    vegas_ttms = List()
    for ttm, forward, vols_ttm, strikes_ttm, optypes_ttm in zip(
        ttms, forwards, vols_ttms, strikes_ttms, types_ttms
    ):
        vegas_ttms.append(
            compute_bsm_slice_vegas(
                ttm=ttm,
                forward=forward,
                strikes=strikes_ttm,
                vols=vols_ttm,
                optypes=optypes_ttm,
            )
        )
        return vegas_ttms


"""
Gamma
"""


@njit
def bsm_gamma(ttm: float, forward: float, strike: float, vol: float) -> float:
    """Vectorised bsm gammas for array of aligned strikes, vols, & optypes."""
    if is_intrinsic(ttm=ttm, vol=vol):
        gamma = 0.0
    else:
        sT = vol * np.sqrt(ttm)
        d1 = np.log(forward / strike) / sT + 0.5 * sT
        gamma = npdf(d1) / (forward * sT)
    return gamma


bsm_gamma_vector = np.vectorize(bsm_gamma, doc="Vectorized `bsm_gamma`")


"""
theta
"""


@njit
def bsm_theta(
    ttm: float,
    forward: float,
    strike: float,
    vol: float,
    optype: str,
    discfactor: float = 1.0,
    discount_rate: float = 0.0,
) -> float:
    """Vectorised bsm thetas for array of aligned strikes, vols, & optypes."""
    if is_intrinsic(ttm=ttm, vol=vol):
        theta = 0.0
    else:
        sT = vol * np.sqrt(ttm)
        d1 = np.log(forward / strike) / sT + 0.5 * sT
        d2 = d1 - sT
        if optype == "C" or optype == "IC":
            theta = -forward * npdf(d1) * vol / (
                0.5 * np.sqrt(ttm)
            ) - discount_rate * discfactor * strike * ncdf(d2)
        elif optype == "P" or optype == "IP":
            theta = -forward * npdf(d1) * vol / (
                0.5 * np.sqrt(ttm)
            ) + discount_rate * discfactor * strike * ncdf(-d2)
        else:
            raise NotImplementedError(f"Option optype {optype} not implemented")
    return theta


bsm_theta_vector = np.vectorize(bsm_theta, doc="Vectorized `bsm_theta`")


@njit
def compute_bsm_slice_vegas(
    ttm: float,
    forward: float,
    strikes: np.ndarray,
    vols: np.ndarray,
    optypes: np.ndarray = None,
) -> np.ndarray:
    """Vectorized bsm vegas for array of aligned strikes, vols, & optypes."""
    sT = vols * np.sqrt(ttm)
    d1 = np.log(forward / strikes) / sT + 0.5 * sT
    vegas = forward * npdf(d1) * np.sqrt(ttm)
    return vegas


@njit
def compute_bsm_vega_ttms(
    ttms: np.ndarray,
    forwards: np.ndarray,
    strikes_ttms: List[np.ndarray],
    vols_ttms: List[np.ndarray],
    optypes_ttms: List[np.ndarray],
) -> List[np.ndarray]:
    """Vectorised bsm vegas for array of aligned strikes, vols, and optypes."""
    vegas_ttms = List()
    for ttm, forward, vols_ttms, strikes_ttms, optypes_ttm in zip(
        ttms, forwards, vols_ttms, strikes_ttms, optypes_ttms
    ):
        vegas_ttms.append(
            compute_bsm_slice_vegas(
                ttm=ttm,
                forward=forward,
                strikes=strikes_ttms,
                vols=vols_ttms,
                optypes=optypes_ttm,
            )
        )
    return vegas_ttms


"""
Implied Vols
"""


@njit
def infer_bsm_ivols_from_slice_prices(
    ttm: float,
    forward: float,
    strikes: np.ndarray,
    optypes: np.ndarray,
    model_prices: np.ndarray,
    discfactor: float,
    vol_low: float = 0.01,
    vol_uppr: float = 5.0,
    max_iters: int = 200,
    is_bounds_to_nan: bool = True,
) -> np.ndarray:
    model_vol_ttm = np.zeros_like(strikes)
    for idx, (strike, model_price, optype) in enumerate(
        zip(strikes, model_prices, optypes)
    ):
        if np.np.isnan(model_price) or np.isclose(model_price, 0.0):
            model_vol_ttm[idx] = np.nan if is_bounds_to_nan else vol_low
        else:
            model_vol_ttm[idx] = infer_bsm_implied_vol(
                forward=forward,
                ttm=ttm,
                discfactor=discfactor,
                given_price=model_price,
                strike=strike,
                optype=optype,
                vol_low=vol_low,
                vol_uppr=vol_uppr,
                max_iters=max_iters,
            )
    return model_vol_ttm


@njit
def infer_bsm_implied_vol(
    forward: float,
    ttm: float,
    given_price: float,
    discfactor: float = 1.0,
    optype: str = "C",
    tol: float = 1e-16,
    vol_low: float = 0.01,
    vol_uppr: float = 5.0,
    max_iters: int = 200,
    is_bounds_to_nan: bool = True,
) -> float:
    """Compute Black IV using bisection on [x_lower, x_upper]."""
    f = (
        bsm_price(
            forward=forward,
            strike=strike,
            ttm=ttm,
            vol=vol_low,
            discfactor=discfactor,
            optype=optype,
        )
        - given_price
    )
    fmid = (
        bsm_price(
            forward=forward,
            strike=strike,
            ttm=ttm,
            vol=vol_uppr,
            discfactor=discfactor,
            optype=optype,
        )
        - given_price
    )

    if f * fmid < 0.0:
        if f < 0.0:
            rtb = vol_low
            dx = vol_uppr - vol_low
        else:
            rtb = vol_uppr
            dx = vol_low - vol_uppr
        xmid = rtb
        for j in range(max_iters):
            dx *= 0.5
            xmid = rtb + dx
            fmid = (
                bsm_price(
                    forward=forward,
                    strike=strike,
                    ttm=ttm,
                    vol=xmid,
                    discfactor=discfactor,
                    optype=optype,
                )
                - given_price
            )
            if fmid <= 0.0:
                rtb = xmid
            if np.abs(fmid) < tol:
                break
        v1 = xmid
    else:  # no solution, fixed to lower bound
        if f < 0.0:
            v1 = vol_low
        else:
            v1 = vol_uppr

    if is_bounds_to_nan:
        if np.abs(v1 - vol_low) < tol or np.abs(v1 - vol_uppr) < tol:
            v1 = np.nan
    return v1


@njit
def infer_bsm_ivols_from_slice_prices(
    ttm: float,
    forward: float,
    discfactor: float,
    strikes: np.ndarray,
    optypes: np.ndarray,
    model_prices: np.ndarray,
) -> np.ndarray:
    """Vectorised chain iv's."""
    model_vol_ttm = np.zeros_like(strikes)
    for idx, (strike, model_price, optype) in enumerate(
        zip(strikes, model_prices, optypes)
    ):
        model_vol_ttm[idx] = infer_bsm_implied_vol(
            forward=forward,
            ttm=ttm,
            discfactor=discfactor,
            given_price=model_price,
            strike=strike,
            optype=optype,
        )
    return model_vol_ttm


@njit
def infer_bsm_ivols_from_model_chain_prices(
    ttms: np.ndarray,
    forwards: np.ndarray,
    discfactors: np.ndarray,
    strikes_ttms: List[np.ndarray],
    optypes_ttms: List[np.ndarray],
    model_prices_ttms: List[np.ndarray],
) -> List[np.ndarray]:
    """Vectorised chain iv's."""
    model_vol_ttms = List()
    for ttm, forward, discfactor, strikes, optypes, model_prices_ttm in zip(
        ttms,
        forwards,
        discfactors,
        strikes_ttms,
        optypes_ttms,
        model_prices_ttms,
    ):
        model_vol = np.zeros_like(strikes)
        for idx, (strike, model_price, optype) in enumerate(
            zip(strikes, model_prices_ttm, optypes)
        ):
            model_vol[idx] = infer_bsm_implied_vol(
                forward=forward,
                ttm=ttm,
                discfactor=discfactor,
                given_price=model_price,
                strike=strike,
                optype=optype,
            )
        model_vol_ttms: append(model_vol)
    return model_vol_ttms


"""
Digital Prices
"""


@njit
def bsm_digital_price(
    forward: float,
    strike: float,
    ttm: float,
    vol: float,
    optype: str = "C",
    discfactor: float = 1.0,
) -> float:
    """BSM pricer for forward."""
    if is_intrinsic(ttm=ttm, vol=vol):
        if optype == "C" or optype == "IC":
            price = 1.0 if forward >= strike else 0.0
        elif optype == "P" or optype == "IP":
            price = 1.0 if forward <= strike else 0.0
        else:
            raise NotImplementedError(f"optype")
    else:
        s_ttm = vol * np.sqrt(ttm)
        d1 = (np.log(forward / strike) + 0.5 * s_ttm * s_ttm) / s_ttm
        d2 = d1 - s_ttm
        if optype == "C" or optype == "IC":
            price = discfactor * ncdf(d2)
        elif optype == "P" or optype == "IP":
            price = discfactor * ncdf(-d2)
        else:
            raise NotImplementedError(f"optype")

    return price


@njit
def compute_bsm_digital_delta(
    forward: float,
    strike: float,
    ttm: float,
    vol: float,
    optype: str = "C",
    discfactor: float = 1.0,
) -> float:
    """BSM pricer for forward."""
    if is_intrinsic(ttm=ttm, vol=vol):
        delta = 0.0
    else:
        s_ttm = vol * np.sqrt(ttm)
        d1 = (np.log(forward / strike) + 0.5 * s_ttm * s_ttm) / s_ttm
        d2 = d1 - s_ttm
        pnorm = discfactor / (forward * s_ttm)
        if optype == "C" or optype == "IC":
            delta = pnorm * npdf(d2)
        elif optype == "P" or optype == "IP":
            delta = -pnorm * npdf(d2)
        else:
            raise NotImplementedError(f"optype")

    return delta


# import numpy as np
# import pandas as pd
# import pytz, os
# %%

# from mpl_toolkits.mplot3d import Axes3D
# from IPython.display import display
# import matplotlib.pyplot as plt
# import altair as alt
# import scipy.stats as si
# from datetime import datetime, timezone
# from datetime import date, time
# from scipy.optimize import minimize


# %%
# obb.user.preferences.output_type = "dataframe"
# chains = obb.derivatives.options.chains(symbol="AAPL", provider="cboe")
# print(f"AAPL chains: {chains}")

# weights = np.array([0.5, 0.5])

# returns = np.array([0.08, 0.12])
# _sigma = np.array([0.2, 0.3])

# port_ret = np.dot(weights, returns)
# port_sigma = np.sqrt(np.dot(weights**2, _sigma**2))

# print(
#     f"Portfolio return: {port_ret:.2f}\nPortfolio standard deviation: {port_sigma:.2f}"
# )
