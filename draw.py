"""Draw rectangles (dimensions in mm) into an SVG sheet."""

import argparse
import subprocess
import tempfile
import time

from render import make_svg, svg_size
from shapes import MARGIN, Pane

INNER_WIDTH = 100
TOTAL_HEIGHT = 80

# printer shrink compensation: printed test measured 119/120 and 286/288 of expected
PRINT_SCALE = 1.0077


def xdg_open_temp(contents: bytes, suffix: str) -> None:
    with tempfile.NamedTemporaryFile("wb", suffix=suffix) as f:
        f.write(contents)
        f.flush()
        subprocess.run(["xdg-open", f.name], check=True)
        # closing deletes the file; give async viewers time to read it first
        time.sleep(2)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--part", choices=("outer", "inner"), required=True,
                        help="which part to draw")
    parser.add_argument("--measure", action="store_true",
                        help="print the SVG size in mm and exit")
    parser.add_argument("-o", "--output",
                        help="write the SVG to this path instead of opening it")
    args = parser.parse_args()

    shapes = []

    def_x = MARGIN
    last_y = MARGIN
    def shape(*, x: int | None = None, y: int | None = None, w: int = INNER_WIDTH, h: int, label: str = "", top: bool = False, bottom: bool = False):
        nonlocal last_y
        shapes.append(Pane(x=x or def_x, y=y or last_y, w=w, h=h, label=label, top=top, bottom=bottom))
        last_y = (y or last_y) + h

    match args.part:
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

    if args.measure:
        w, h = svg_size(shapes)
        print(f"{w:g} x {h:g} mm")
        return

    svg = make_svg(shapes, scale=PRINT_SCALE)
    if args.output:
        with open(args.output, "wb") as f:
            f.write(svg)
        print(f"wrote {args.output}")
    else:
        xdg_open_temp(svg, ".svg")


if __name__ == "__main__":
    main()
