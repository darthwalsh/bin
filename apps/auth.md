Sometimes it's easier to use "Auth" instead of specifying authentication vs authorization.
## HTTP Status Codes
Great answer from https://stackoverflow.com/a/57376260/771768:
- `401` UNAUTHORIZED:  I don't know who you are. _This an **authentication** error._
- `403` FORBIDDEN: I know who you are, but you don't have permission. _This is an **authorization** error._

## Capabilities
Many vulnerabilities in web servers would be fixed by not answer the "auth" question with a boolean, but instead tracking Capabilities
http://habitatchronicles.com/2017/05/what-are-capabilities/

>A **capability** is single thing that both designates a resource and authorizes some kind of access to it.

Interesting story about an early hack: using the system itself to overwrite a sensitive file:
>Then one day somebody figured out they could tell the compiler the name of the system accounting file as the name of the file to write the compilation output to. 
>Fixing this turned out to be surprisingly slippery. Norm named the underlying problem “The Confused Deputy”
- [ ] read http://cap-lore.com/CapTheory/ConfusedDeputy.html


>Norm Hardy’s “don’t separate designation from authority” motto
- [ ] Read the rest of http://habitatchronicles.com/2017/05/what-are-capabilities/