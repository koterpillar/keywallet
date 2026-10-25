"""Draw rectangles (dimensions in mm) into a printable A4 sheet."""

from shapes import Rect
from svgprint import make_svg, print_sheet

A4 = (210, 297)


def main():
    # Edit these: your rectangles.
    rects = [
        Rect(x=10, y=10, w=60, h=30, label="60 x 30"),
        Rect(x=80, y=10, w=25, h=25, label="25 x 25"),
    ]

    svg = make_svg(A4, rects)
    with open("output.svg", "w") as f:
        f.write(svg)
    print(f"wrote output.svg ({A4[0]} x {A4[1]} mm)")
    print_sheet(svg, A4)


if __name__ == "__main__":
    main()
