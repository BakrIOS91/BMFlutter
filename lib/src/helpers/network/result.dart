/// Result Type for BMFlutter Network Layer
/// 
/// This file provides a comprehensive Result type implementation for handling
/// operations that can either succeed or fail. It uses the sealed class pattern
/// to ensure type safety and exhaustive pattern matching, similar to Rust's
/// Result type or Swift's Result type.
/// 
/// The Result type eliminates the need for exceptions in many cases and provides
/// a more explicit way to handle errors. It includes convenience methods for
/// pattern matching, value extraction, and functional transformations.
/// 
/// Usage:
/// ```dart
/// // Create success result
/// final success = Success<String, String>('Hello World');
/// 
/// // Create failure result
/// final failure = Failure<String, String>('Error occurred');
/// 
/// // Pattern matching
/// result.when(
///   success: (value) => print('Success: $value'),
///   failure: (error) => print('Error: $error'),
/// );
/// ```

/// Represents the result of an operation: either success or failure
/// 
/// This sealed class provides a type-safe way to handle operations that can
/// either succeed with a value or fail with an error. It uses generic types
/// S for success value and E for error type, providing maximum flexibility.
sealed class Result<S, E> {
  /// Private constructor for the sealed class
  const Result();

  /// Convenience method to handle success or failure with callbacks
  /// 
  /// This method provides a functional approach to handling Result values
  /// by accepting two callback functions - one for success and one for failure.
  /// It automatically determines which callback to call based on the Result type.
  /// 
  /// Parameters:
  /// - [success]: Callback to execute when the result is successful
  /// - [failure]: Callback to execute when the result is a failure
  void when({required void Function(S value) success, required void Function(E error) failure}) {
    if (this is Success<S, E>) {
      success((this as Success<S, E>).value);
    } else if (this is Failure<S, E>) {
      failure((this as Failure<S, E>).error);
    }
  }

  /// Returns the value if success, otherwise null
  /// 
  /// This getter provides a convenient way to extract the success value
  /// without pattern matching. It returns null if the result is a failure.
  /// 
  /// Returns the success value or null if failure
  S? get value => this is Success<S, E> ? (this as Success<S, E>).value : null;

  /// Returns the error if failure, otherwise null
  /// 
  /// This getter provides a convenient way to extract the error value
  /// without pattern matching. It returns null if the result is a success.
  /// 
  /// Returns the error value or null if success
  E? get error => this is Failure<S, E> ? (this as Failure<S, E>).error : null;

  /// True if the result is a success
  /// 
  /// This getter provides a boolean check for success without needing
  /// to access the value. It's useful for conditional logic.
  /// 
  /// Returns true if success, false if failure
  bool get isSuccess => this is Success<S, E>;

  /// True if the result is a failure
  /// 
  /// This getter provides a boolean check for failure without needing
  /// to access the error. It's useful for conditional logic.
  /// 
  /// Returns true if failure, false if success
  bool get isFailure => this is Failure<S, E>;
}

/// Successful result containing a value of type S
/// 
/// This class represents a successful operation result. It contains the
/// actual value that was produced by the operation and can be safely
/// accessed without null checks.
class Success<S, E> extends Result<S, E> {
  /// The successful value produced by the operation
  @override
  final S value;
  
  /// Creates a new Success result
  /// 
  /// Parameters:
  /// - [value]: The successful value to wrap
  const Success(this.value);
}

/// Failure result containing an error of type E
/// 
/// This class represents a failed operation result. It contains the
/// error information that describes what went wrong during the operation.
class Failure<S, E> extends Result<S, E> {
  /// The error that occurred during the operation
  @override
  final E error;
  
  /// Creates a new Failure result
  /// 
  /// Parameters:
  /// - [error]: The error that occurred
  const Failure(this.error);
}

/// Helper extension to map success values and errors
/// 
/// This extension provides functional programming methods for transforming
/// Result values. It includes methods for mapping success values to different
/// types and mapping errors to different error types, similar to functional
/// programming patterns in other languages.
extension ResultMapping<S, E> on Result<S, E> {
  /// Maps the success value to a different type
  /// 
  /// This method applies a transformation function to the success value
  /// if the result is successful, or preserves the error if the result is
  /// a failure. This is useful for converting success values to different types.
  /// 
  /// Parameters:
  /// - [transform]: Function to transform the success value
  /// 
  /// Returns a new Result with the transformed success value or original error
  Result<R, E> map<R>(R Function(S value) transform) {
    if (this is Success<S, E>) {
      return Success<R, E>(transform((this as Success<S, E>).value));
    } else {
      return Failure<R, E>((this as Failure<S, E>).error);
    }
  }

  /// Maps the error to a different error type
  /// 
  /// This method applies a transformation function to the error value
  /// if the result is a failure, or preserves the success value if the result
  /// is successful. This is useful for converting errors to different types.
  /// 
  /// Parameters:
  /// - [transform]: Function to transform the error value
  /// 
  /// Returns a new Result with the original success value or transformed error
  Result<S, F> mapError<F>(F Function(E error) transform) {
    if (this is Failure<S, E>) {
      return Failure<S, F>(transform((this as Failure<S, E>).error));
    } else {
      return Success<S, F>((this as Success<S, E>).value);
    }
  }
}
