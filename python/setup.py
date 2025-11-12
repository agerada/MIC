"""Setup script for mic-py package."""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="mic-py",
    version="0.1.0",
    author="Alessandro Gerada",
    author_email="alessandro.gerada@liverpool.ac.uk",
    description="Python interface for the MIC R package",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/agerada/MIC",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=[
        # rpy2 should be installed via system packages for best compatibility
        # Ubuntu/Debian: sudo apt-get install python3-rpy2
        # Or via pip: pip install rpy2>=3.5.0
    ],
    extras_require={
        "pip": ["rpy2>=3.5.0"],
    },
)
