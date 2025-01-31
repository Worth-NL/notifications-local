# NotifyNL Local Environment

> [!IMPORTANT]  
> Current operating systems supported are ***MacOS, Ubuntu and Windows (using an Ubuntu WSL2)***.
> For all others, you are on your own (though you can always ask @pgaetani).

## Pre-requirements
- [Install Docker](https://docs.docker.com/desktop/)
- [Install VSCode](https://code.visualstudio.com/)
- Ask someone in the [@admins](https://github.com/orgs/Worth-NL/teams/worth-admins) group for an AWS user and an IAM role.
- [Create a key and secret pair for said IAM role.](docs/long_install.md#aws)

## The Short Version
> [!WARNING]  
> Makefile still under construction.
> 
> Use [the long way to install](docs/long_install.md).

Generate your environment variable files:
```sh
make configure
```

To install the requirements:
```sh
make setup
```

To run the environment:
```sh
make up
```

To stop the environment:
```sh
make down
```

## Further Reading
- [User credentials](docs/credentials.md)
- [Recommended VSCode Extensions](docs/vscode.md#recommended-extensions)
- [VSCode setup](docs/vscode.md#setup)
- [The long way to install](docs/long_install.md)
---
- [Old Documentation](.old/README.md)