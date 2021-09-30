# SpanGrid

> SpanGrid is an enriched SwiftUI [`LazyVGrid`](https://developer.apple.com/documentation/swiftui/lazyvgrid) that supports a number of extra features.

## Features

### Column Span

All items in the data source must conform to `SpanGridSizeInfoProvider`. This protocol adds a single parameter to your
data which informs the grid as to how many columns it should fill.

Options include:
* A single `cell` which is the same width as a column.
* A full `row` which will cover all columns, no matter how many columns there are.
* A custom `span` which allows you to specify the exact number of columns. If the value provided is larger than the number of columns, then it will fill the row.

If a cell cannot fit in the remaining space of a row, then it will create a new row leaving whitespace on the previous one.

### Row Size Strategy

When returning your custom view for each cell, it will arrive with a metadata model. This model will include information
such as the calculated height of the row. This value may also be `nil` in scenarios where we have yet to calculate it.

Options include:
* A `fixed` size where all rows will be the same height that you have provided.
* `square` where the height of each row is the same as the width of a single column. If your row contains a span of >1, it will still only return the width of a single column.
* `largest` will return the height of the largest cell in the row allowing for all cells to be of equal height.
* `none` (default) will never return a height.

### Column Size Strategy

The width of a single column, the number of columns and the space between columns can be calculated in a number of ways.

Options include:
* A `fixed` provider which allows you to strictly specify the three values above.
* `dynamic` (default) provides an opinionated column structure which adapts to the size of the device and includes some accessibility changes.
* `custom` allows you to provide your own implementation. This will provide you with the current width of the grid. 

## Notes

I do not pledge to be an expert in SwiftUI, so there may be many issues with the current implementation. I have tested it
the best I can and have seen no real issues with performance or functionality. Feel free to raise issues or pull requests
with enhancements, bug fixes, ideas, etc.

No Jordan, this project is **not** called Spandex, no matter how many times you say it.
