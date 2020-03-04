"""
Pythy server-side support module.

This module contains core classes used by Pythy when student code is
executed on the server (such as when reference tests are being checked).
"""


__all__ = ['TestCase', 'TestRunner', 'runAllTests']

__pythy = True

from .test import TestCase, TestRunner, runAllTests
