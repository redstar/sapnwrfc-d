D bindings for SAP NetWeaver RFC SDK
====================================

Summary
-------

This library provides bindings [D programming language](http://dlang.org) for the SAP NetWeaver RFC SDK. It allows you to call SAP RFC's using D.

Prerequisite
------------

You need to download and install the SAP NetWeaver RFC SDK for your OS from http://service.sap.com/swdc. For further information see SAP note 1025361.
The SAP NetWeaver RFC SDK is copyrighted software and is only available through the official channels mentioned above. It is strongly recommended to download the provided SDK documentation, too.

Installation
------------

If you use [dub](https://github.com/rejectedsoftware/dub/) then you only need to add `sapnwrfc-d` to the dependencies of your project in the `dub.json` file:

    {
        /* Other stuf */
        "dependencies": {
            /* Other dependencies */
            "sapnwrfc-d"
        }
    }

Otherwise you have to compile all D files in the `source` folder into a library named `libsapnwrfc-d.a` (Linux) or `sapnwrfc-d.lib` (Windows).
You also need to link against the libraries provided by the SAP NetWeaver RFC SDK. (Currently, only `libsapnwrfc.a`/`sapnwrfc.lib` is required.)

Examples
--------

Examples are provided in the `examples` folder.

Limitations
-----------

- Currently there are no bindings for the decimal data types `DecFloat16` and `DecFloat34`.
- The prototypes are still reworked to use `out` and other type modifiers.
- A high level API is missing. Ideas include:
  - An exception should be used instead of return code checking
  - The C style string handling should be replaced with D strings
  - Data containers should provide a range interface
  - ...

License
-------

This project is distributed under the BSD 3-clause licence.