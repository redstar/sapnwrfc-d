D bindings for SAP NetWeaver RFC SDK
====================================

Summary
-------

This library provides bindings [D programming language](http://dlang.org) for the SAP NetWeaver RFC SDK. It allows you to call SAP RFC's using D.

Prerequisite
------------

You need to download and install the SAP NetWeaver RFC SDK for your OS from https://support.sap.com/swdc. For further information see [SAP note 1025361](http://service.sap.com/sap/support/notes/1025361).
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

Examples are provided in the `examples` [folder](https://github.com/redstar/sapnwrfc-d/tree/master/examples/).

- sapping connects to a SAP system and retrieves some system information. Useful for connection tests.
- readtable calls RFC_READ_TABLE and exports the content of a database table.
- repotool (WIP) displays the metadata for a function

Functionality
-------------

- Prototypes for (most) C functions of the SAP NetWeaver RFC SDK.
- Decorated functions which throw a `SAPException` in case of error.

The functions of the SDK are imported with `import etc.c.sapnwrfc;`. This is the C API as documented in the SDK.
You get additonally functionality if you use `import std.sap;`. Each function from the C API is available. All functions which have an `ERROR_INFO` parameter have an overloaded prototype without this argument. In case of an error these functions throw a `SAPException`.
The use of module `std.sap` should be preferred because of the much easier error handling.

Limitations
-----------

- The prototypes are still reworked to use `out` and other type modifiers.
- A high level API is missing. Ideas include:
  - The C style string handling should be replaced with D strings
  - Data containers should provide a range interface
  - ...

License
-------

This project is distributed under the BSD 3-clause licence.