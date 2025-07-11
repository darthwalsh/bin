
## Related Terms
#ai-slop 
- **Marshalling / Unmarshalling** often appear in remoting/cooperation frameworks (e.g., RPC, XML serialization).
- **Serialization / Deserialization** is broader, used in file I/O, caches, messaging, etc.
- **Encoding / Decoding** is more generic and may include normalization (e.g., JSON to structs).
- **Parsing** often refers to extracting or interpreting data, especially from text formats (XML, JSON).
- **Materialization/Hydration** emphasize building complex object state from data storage.

A *different* term is **Encryption / Decryption** which intentionally scrambles the data to keep it secret.
## C\#
In my [dotnetbytes project](https://github.com/darthwalsh/dotNetBytes/blob/f78ae096b3f813a814ed12ba2ae5a01efddb7913/Lib/Extensions.cs#L85C13-L85C20), I used `Marshal.PtrToStructure` to cast `byte[]` to any `struct`. 
Then each[ data type to be parsed](https://github.com/darthwalsh/dotNetBytes/blob/f78ae096b3f813a814ed12ba2ae5a01efddb7913/Lib/FileFormat.cs#L12) subclasses `CodeNode`.
## rust
https://crates.io/crates/bytemuck is 