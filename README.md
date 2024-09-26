# Lazy GitLab Runner Kubernetes Terraform Module

This module provides an easy way to deploy GitLab Runners on Kubernetes using Terraform. It is designed to replace the functionality of [terraform-kubernetes-gitlab-runner](https://github.com/MaciekLeks/terraform-kubernetes-gitlab-runner) while addressing some key limitations.

## Why a New Module?

GitLab has been systematically moving configuration attributes to TOML format. To accommodate this shift and provide a more flexible solution, this new module leverages the `Tobotimus/toml` provider. This allows for easier management of TOML configurations within Terraform.

## Why "Lazy"?

I call this module "lazy" because it uses a simple approach, unlike the more complex solutions in the old project. Here's why:

1. **Easy Setup**: We keep things consistent between Terraform and GitLab. For example, if GitLab uses camelCase, we use it in Terraform too. This:
   - Makes things simpler
   - Matches GitLab's own instructions better
   - Helps users switch between GitLab's docs and our module easily

2. **Straightforward Design**: What you put into Terraform is directly reflected in the GitLab Runner setup. This makes it easier to understand and fix if needed.

3. **Clear Structure**: I've removed unnecessary complications, making the module easier to understand and fix problems.

This "lazy" way focuses on keeping things simple and clear. It makes the module easier to use, especially for people who already know how to set up GitLab Runners.


## Key Features

- Simplified deployment of GitLab Runners on Kubernetes
- Utilizes the `Tobotimus/toml` provider for TOML encoding
- Designed to be more adaptable to GitLab's evolving configuration standards

## Getting Started

**Please Note: This module is currently under active development and is not yet ready for production use.**

I'm  working diligently to create a stable and feature-complete version of this module. While we're excited about its potential, we advise against using it in any critical or production environments at this time.

### Development Status

- [x] Core functionality implementation
- [ ] Testing and validation
- [x] Documentation
- [ ] Example configurations
- [ ] First stable release

I appreciate your interest in this project. If you'd like to contribute or stay updated on its progress, please:

1. Star this repository to show your support
2. Watch this repository for updates
3. Check the Issues tab for current development tasks and known issues


## Contributing

Contributions are welcome! Just write an issue and create a pull request.

## License

This project is free to use and distribute under the MIT License. See [LICENSE](https://mit-license.org) for more information.

## API Documentation


