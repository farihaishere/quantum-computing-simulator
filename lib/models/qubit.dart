import 'dart:math' as math;

/// Represents a complex number with real and imaginary parts.
class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);
  const Complex.zero() : real = 0, imaginary = 0;
  const Complex.one() : real = 1, imaginary = 0;
  const Complex.i() : real = 0, imaginary = 1;

  factory Complex.fromPolar(double r, double theta) =>
      Complex(r * math.cos(theta), r * math.sin(theta));

  Complex operator +(Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) =>
      Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) => Complex(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );

  Complex operator /(double scalar) => Complex(real / scalar, imaginary / scalar);

  Complex scale(double s) => Complex(real * s, imaginary * s);

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);
  double get magnitudeSquared => real * real + imaginary * imaginary;
  double get phase => math.atan2(imaginary, real);

  Complex get conjugate => Complex(real, -imaginary);

  @override
  String toString() {
    if (imaginary == 0) return real.toStringAsFixed(3);
    if (real == 0) return '${imaginary.toStringAsFixed(3)}i';
    final sign = imaginary >= 0 ? '+' : '';
    return '${real.toStringAsFixed(3)}$sign${imaginary.toStringAsFixed(3)}i';
  }

  @override
  bool operator ==(Object other) =>
      other is Complex &&
      (real - other.real).abs() < 1e-10 &&
      (imaginary - other.imaginary).abs() < 1e-10;

  @override
  int get hashCode => Object.hash(real, imaginary);
}

/// A quantum state represented as a statevector of complex amplitudes.
/// For n qubits, there are 2^n amplitudes.
class Qubit {
  final List<Complex> amplitudes;
  final int numQubits;

  Qubit(this.numQubits)
      : amplitudes = List.generate(
          1 << numQubits,
          (i) => i == 0 ? const Complex.one() : const Complex.zero(),
        );

  Qubit.fromAmplitudes(this.amplitudes)
      : numQubits = (math.log(amplitudes.length) / math.ln2).round();

  Qubit.fromState(this.numQubits, this.amplitudes);

  /// Returns the probability of measuring each basis state.
  List<double> get probabilities =>
      amplitudes.map((a) => a.magnitudeSquared).toList();

  /// Returns the basis state labels e.g. |00⟩, |01⟩ ...
  List<String> get basisLabels => List.generate(
        1 << numQubits,
        (i) => '|${i.toRadixString(2).padLeft(numQubits, '0')}⟩',
      );

  /// Normalize the statevector so total probability = 1.
  Qubit normalize() {
    final norm = math.sqrt(amplitudes.fold(0.0, (s, a) => s + a.magnitudeSquared));
    if (norm < 1e-12) return this;
    return Qubit.fromAmplitudes(amplitudes.map((a) => a / norm).toList());
  }

  /// Returns the most probable measurement outcome.
  int get mostProbableState {
    final probs = probabilities;
    return probs.indexOf(probs.reduce(math.max));
  }

  /// Bloch sphere angles for a single qubit (only valid when numQubits == 1).
  /// theta: polar angle, phi: azimuthal angle
  (double theta, double phi) get blochAngles {
    if (numQubits != 1) return (0, 0);
    final alpha = amplitudes[0]; // |0⟩ amplitude
    final beta = amplitudes[1];  // |1⟩ amplitude
    final theta = 2 * math.acos(alpha.magnitude.clamp(0.0, 1.0));
    final phi = beta.phase - alpha.phase;
    return (theta, phi);
  }

  @override
  String toString() {
    final buf = StringBuffer();
    for (int i = 0; i < amplitudes.length; i++) {
      if (amplitudes[i].magnitude > 1e-6) {
        buf.write('(${amplitudes[i]})${basisLabels[i]} ');
      }
    }
    return buf.toString().trim();
  }
}
