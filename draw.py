"""Draw rectangles (dimensions in mm) into a printable A4 sheet."""

import argparse

from shapes import MARGIN, Pane
from render import make_svg, make_html

A4 = (210, 297)


INNER_WIDTH = 100


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--print", action="store_true",
                        help="open the print dialog automatically")
    parser.add_argument("--part", choices=("outer", "inner"),
                        help="draw only this part (default: both)")
    args = parser.parse_args()

    shapes = []

    def_x = MARGIN
    last_y = MARGIN
    def shape(*, x: int | None = None, y: int | None = None, w: int = INNER_WIDTH, h: int, label: str = "", top: bool = False, bottom: bool = False):
        nonlocal last_y
        shapes.append(Pane(x=x or def_x, y=y or last_y, w=w, h=h, label=label, top=top, bottom=bottom))
        last_y = (y or last_y) + h

    parts = (args.part,) if args.part else ("outer", "inner")
    for part in parts:
        match part:
            case "outer":
                shape(h=60, label="2", top=True)
                shape(h=1)
                shape(h=60, label="1")
                shape(h=11)
                shape(h=80, label="6")
                shape(h=6)
                shape(h=50, label="3б", bottom=True)
            case "inner":
                shape(h=20, label="3а", top=True)
                shape(h=3)
                shape(h=80, label="5")
                shape(h=2)
                shape(h=65, label="4", bottom=True)
            case _:
                raise ValueError(f"Unknown part: {part}")

    with make_svg(A4, shapes) as svg_path:
        make_html(svg_path, A4, auto_print=args.print)


if __name__ == "__main__":
    main()
