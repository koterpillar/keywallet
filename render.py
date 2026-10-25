"""SVG/printing framework: build sheets from shapes, open the print dialog."""

import os
import tempfile
import webbrowser
import xml.etree.ElementTree as ET
from contextlib import contextmanager
from typing import Protocol

SVG_NS = "http://www.w3.org/2000/svg"


class Shape(Protocol):
    def add_to(self, svg: ET.Element) -> None: ...


@contextmanager
def make_svg(sheet: tuple[float, float], shapes: list[Shape]):
    ET.register_namespace("", SVG_NS)
    svg = ET.Element(f"{{{SVG_NS}}}svg", {
        "width": f"{sheet[0]}mm",
        "height": f"{sheet[1]}mm",
        "viewBox": f"0 0 {sheet[0]} {sheet[1]}",
    })
    for s in shapes:
        s.add_to(svg)
    # delete=False: the file must be readable inside the with-block; removed on exit.
    with tempfile.NamedTemporaryFile("w", suffix=".svg", delete=False) as f:
        f.write(ET.tostring(svg, encoding="unicode"))
    yield f.name
    os.unlink(f.name)


def make_html(svg_path: str, sheet: tuple[float, float], auto_print: bool = False) -> None:
    with open(svg_path) as f:
        svg = f.read()
    # @page sets the sheet size so the browser prints at 1:1 without scaling.
    script = "<script>window.print()</script>" if auto_print else ""
    html = (
        f"<!doctype html><style>@page {{ size: {sheet[0]}mm {sheet[1]}mm; margin: 0; }}"
        f"body {{ margin: 0; }}</style>"
        f"{svg}{script}"
    )
    # delete=False: the browser loads it asynchronously, so it must survive this
    # process; the OS temp dir cleans it up.
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(html)
    print("opening browser...")
    webbrowser.open(f"file://{f.name}")
