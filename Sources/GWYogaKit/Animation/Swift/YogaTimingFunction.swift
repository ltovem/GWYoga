import Foundation

// MARK: - YogaStepPosition

public enum YogaStepPosition: Sendable {
    case start
    case end
}

// MARK: - YogaTimingFunction

/// CSS timing function — maps linear progress [0, 1] to eased progress.
public enum YogaTimingFunction: Sendable {
    case linear
    case ease
    case easeIn
    case easeOut
    case easeInOut
    case cubicBezier(Float, Float, Float, Float)
    case steps(Int, stepPosition: YogaStepPosition)

    /// Map a linear progress value (0.0–1.0) through this timing function.
    public func map(_ progress: Float) -> Float {
        let p = clamp(progress, min: 0, max: 1)
        switch self {
        case .linear:
            return p
        case .ease:
            return cubicBezier(p, 0.25, 0.1, 0.25, 1.0)
        case .easeIn:
            return cubicBezier(p, 0.42, 0.0, 1.0, 1.0)
        case .easeOut:
            return cubicBezier(p, 0.0, 0.0, 0.58, 1.0)
        case .easeInOut:
            return cubicBezier(p, 0.42, 0.0, 0.58, 1.0)
        case .cubicBezier(let x1, let y1, let x2, let y2):
            return cubicBezier(p, x1, y1, x2, y2)
        case .steps(let count, let position):
            return step(p, count: count, position: position)
        }
    }

    // MARK: - Private Helpers

    private func cubicBezier(_ t: Float, _ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) -> Float {
        // Newton-Raphson to solve for t given x, then evaluate y
        let epsilon: Float = 1e-6
        var guess = t
        for _ in 0..<8 {
            let x = sampleCurveX(guess, x1: x1, x2: x2)
            if abs(x - t) < epsilon { break }
            let dx = sampleCurveDerivativeX(guess, x1: x1, x2: x2)
            if abs(dx) < epsilon { break }
            guess -= (x - t) / dx
        }
        return sampleCurveY(guess, y1: y1, y2: y2)
    }

    private func sampleCurveX(_ t: Float, x1: Float, x2: Float) -> Float {
        ((1 - t) * 3 * (1 - t) * t * x1) + (3 * t * t * (1 - t) * x2) + (t * t * t)
    }

    private func sampleCurveY(_ t: Float, y1: Float, y2: Float) -> Float {
        ((1 - t) * 3 * (1 - t) * t * y1) + (3 * t * t * (1 - t) * y2) + (t * t * t)
    }

    private func sampleCurveDerivativeX(_ t: Float, x1: Float, x2: Float) -> Float {
        (3 * (1 - t) * (1 - t) * x1) + (6 * t * (1 - t) * (x2 - x1)) + (3 * t * t * (1 - x2))
    }

    private func step(_ t: Float, count: Int, position: YogaStepPosition) -> Float {
        let clamped = clamp(t, min: 0, max: 1)
        let stepSize = 1.0 / Float(max(count, 1))
        let offset: Float = position == .start ? 0 : stepSize
        let stepsCompleted = Int(clamped / stepSize + offset / stepSize)
        return Float(stepsCompleted) * stepSize
    }

    private func clamp(_ value: Float, min: Float, max: Float) -> Float {
        value < min ? min : (value > max ? max : value)
    }
}
