Goals of putting secrets into your version control
- Encrypted so nobody can see the plaintext
- Share with teammates so you aren't all juggling secrets
- Versioned together with application code
## One secret to encrypt github repo
Using GCP KMS:
https://github.com/darthwalsh/FireSocket/blob/8183fff9f76daf93e38a0251a2c8c5e56f054461/cloudbuild.yaml#L26

[Encrypting content with Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/vault_encrypting_content.html)

[git-crypt](https://www.agwa.name/projects/git-crypt/) does not [sound](https://news.ycombinator.com/item?id=42252243) like a well-maintained project, but that recommends some other choices:
- [https://www.passwordstore.org/](https://www.passwordstore.org/)
- [https://github.com/getsops/sops](https://github.com/getsops/sops)
- [https://www.vaultproject.io/](https://www.vaultproject.io/)
- [https://infisical.com/](https://infisical.com/)

At work I've used HashCorp Vault for secrets, and it works OK