import CoreGraphics

// eg. percentOf(viewHeight, percentage: 20)
func percentOf(_ value: CGFloat, percentage: Int) -> CGFloat {
    return value * percent(percentage)
}

private func percent(_ percentage: Int) -> CGFloat {
    return (CGFloat(percentage) / 100.0)
}
