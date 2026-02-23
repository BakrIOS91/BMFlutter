/// DI Environments and Types for Riverpod code generation.
/// This file must NOT import any Flutter-specific packages (like flutter/material.dart).
library;

/// DI Environments
enum DIEnvironment {
  live, // default environment
  mock, // for testing purposes
}

/// Type of provider to generate
enum ProviderType {
  singleton, // default Provider
  factory, // autoDispose Provider
  statefulSingleton, // NotifierProvider
}
