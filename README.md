# Czoodle

This is a mirror of private repository for source code of https://czoodle.cz - group poll service

The project is still rather a prototype, code needs major refactoring.

# Features

- End-to-end encryption
- Simple proof-of-work required to create a project instead of captcha or email verification
- Competition for offered project key may work as prevention of DDoS attacks
- Detection of collisions and patching of changes on the client-side (mandatory because of the encryption)

# TODO

- Choose Elm project structure and refactor front-end code
- Better response codes from the server
- Multi-threaded back-end and locking of projects being touched
- Internationalization
- Edit options in existing project
- Support for comments in projects
