# Code Climate tfsec plugin

`codeclimate-tfsec` is a Code Climate plugin that wraps [tfsec](https://github.com/aquasecurity/tfsec). You can run it on your command line using the Code Climate CLI, or on our hosted analysis platform.

### Installation

1. If you haven't already, [install the Code Climate CLI](https://github.com/codeclimate/codeclimate).
2. Add the following to your Code Climate config:
  ```yaml
  plugins:
    tfsec:
      enabled: true
      channel: beta
  ```
3. Run `codeclimate engines:install`
4. You're ready to analyze! Browse into your project's folder and run `codeclimate analyze`.

### Building

```console
make image
```

This will build a `codeclimate/codeclimate-tfsec` image locally.

### Need help?

For help with tfsec, [check out their documentation](https://github.com/aquasecurity/tfsec).

If you're running into a Code Climate issue, first look over this project's [GitHub Issues](https://github.com/aquasecurity/tfsec/issues), as your question may have already been covered. If not, [go ahead and open a support ticket with us](https://codeclimate.com/help).

# Test!
