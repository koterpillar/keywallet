"""SVG/printing framework: build sheets from shapes, open the print dialog."""

import os
import webbrowser
import xml.etree.ElementTree as ET
from typing import Protocol

SVG_NS = "http://www.w3.org/2000/svg"


class Shape(Protocol):
    def add_to(self, svg: ET.Element) -> None: ...


def make_svg(sheet: tuple[float, float], shapes: list[Shape]) -> str:
    ET.register_namespace("", SVG_NS)
    svg = ET.Element(f"{{{SVG_NS}}}svg", {
        "width": f"{sheet[0]}mm",
        "height": f"{sheet[1]}mm",
        "viewBox": f"0 0 {sheet[0]} {sheet[1]}",
    })
    for s in shapes:
        s.add_to(svg)
    return ET.tostring(svg, encoding="unicode")


def print_sheet(svg: str, sheet: tuple[float, float]) -> None:
    # @page sets the sheet size so the browser prints at 1:1 without scaling.
    html = (
        f"<!doctype html><style>@page {{ size: {sheet[0]}mm {sheet[1]}mm; margin: 0; }}"
        f"body {{ margin: 0; }}</style>"
        f"{svg}<script>window.print()</script>"
    )
    html_path = "print.html"
    with open(html_path, "w") as f:
        f.write(html)
    print("opening print dialog...")
    here = os.path.dirname(os.path.abspath(__file__))
    webbrowser.open(f"file://{here}/{html_path}")
