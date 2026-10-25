"""Draw rectangles (dimensions in mm) into a printable A4 sheet."""

import sys

from shapes import MARGIN, Pane
from svgprint import make_svg, print_sheet

A4 = (210, 297)


INNER_WIDTH = 100


def main():
    shapes = []

    def_x = MARGIN
    last_y = MARGIN
    def shape(*, x: int | None = None, y: int | None = None, w: int = INNER_WIDTH, h: int, label: str = "", top: bool = False, bottom: bool = False):
        nonlocal last_y
        shapes.append(Pane(x=x or def_x, y=y or last_y, w=w, h=h, label=label, top=top, bottom=bottom))
        last_y = (y or last_y) + h

    shape(h=60, label="2", top=True)
    shape(h=1)
    shape(h=60, label="1")
    shape(h=11)
    shape(h=80, label="6")
    shape(h=6)
    shape(h=50, label="3б", bottom=True)
    print(f"def_x={def_x}, last_y={last_y}")

    def_x = def_x + INNER_WIDTH + MARGIN + MARGIN + MARGIN
    last_y = MARGIN

    shape(h=20, label="3а", top=True)
    shape(h=3)
    shape(h=80, label="5")
    shape(h=2)
    shape(h=65, label="4", bottom=True)

    svg = make_svg(A4, shapes)
    with open("output.svg", "w") as f:
        f.write(svg)
    print_sheet(svg, A4, auto_print="--print" in sys.argv[1:])


if __name__ == "__main__":
    main()
