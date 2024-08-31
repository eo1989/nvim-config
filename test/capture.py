import sys
from types import FrameType
from typing import Any, Callable, ParamSpec, TypeVar
P = ParamSpec("P")
R = TypeVar("R")


def capture_locals(
    func: Callable[P, R]
) -> Callable[P, tuple[R, dict[str, Any]]]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> tuple[R, dict[str, Any]]:
        f_locals = {}

        def profiler(frame: FrameType, event: str, _: Any) -> None:
            nonlocal f_locals

            if event == "return":
                f_locals = frame.f_locals.copy()

        orig_profiler = sys.getprofile()
        sys.setprofile(profiler)
        try:
            res = func(*args, **kwargs)
        finally:
            sys.setprofile(orig_profiler)
        return res, f_locals

    return wrapper
