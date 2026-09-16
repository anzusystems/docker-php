Configuration
=====

`php.ini`, `php-fpm.conf` and `www.conf` do not contain any hardcoded value that you would have to patch - every
directive we care about is read from an environment variable declared in `template.Dockerfile`. Override the variable
in your `docker-compose.yml` (or `docker run -e`) instead of mounting your own config file.

The config files live in:

- `config/all-X.Y/usr/local/etc/php/php.ini` - per PHP version, all variants
- `config/fpm-X.Y/usr/local/etc/php-fpm.conf` and `config/fpm-X.Y/usr/local/etc/php-fpm.d/www.conf` - per PHP version, fpm variant
- `config/fpm-nginx/etc/nginx/` - nginx variant, driven by the `NGINX_*` variables from `variant-nginx.Dockerfile`

## PHP variables

| Variable                                       | Directive                                  | Default                                                                                                                               |
| ---------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `PHP_ACCESS_LOG`                               | `access.log`                               | `/proc/self/fd/2`                                                                                                                     |
| `PHP_ACCESS_LOG_FORMAT`                        | `access.format`                            | `%R - %u %t "%m %r" %s path:%{REQUEST_URI}e pid:%p took:%ds mem:%{mega}Mmb cpu:%C%% status:%s {%{REMOTE_ADDR}e\|%{HTTP_USER_AGENT}e}` |
| `PHP_CURL_CAINFO`                              | `curl.cainfo`                              | _(empty)_                                                                                                                             |
| `PHP_DATE_TIMEZONE`                            | `date.timezone`                            | `UTC`                                                                                                                                 |
| `PHP_DISPLAY_ERRORS`                           | `display_errors`                           | `0`                                                                                                                                   |
| `PHP_DISPLAY_STARTUP_ERRORS`                   | `display_startup_errors`                   | `0`                                                                                                                                   |
| `PHP_ERROR_LOG`                                | `error_log`                                | `/proc/self/fd/2`                                                                                                                     |
| `PHP_ERROR_REPORTING`                          | `error_reporting`                          | `6143`                                                                                                                                |
| `PHP_EXPOSE_PHP`                               | `expose_php`                               | `0`                                                                                                                                   |
| `PHP_FFI_ENABLED`                              | `ffi.enable`                               | `preload`                                                                                                                             |
| `PHP_LOG_LEVEL`                                | `log_level`                                | `notice`                                                                                                                              |
| `PHP_MAX_EXECUTION_TIME`                       | `max_execution_time`                       | `30`                                                                                                                                  |
| `PHP_MAX_INPUT_VARS`                           | `max_input_vars`                           | `1000`                                                                                                                                |
| `PHP_MAX_MEMORY_LIMIT`                         | `max_memory_limit` (PHP 8.5+)              | `-1`                                                                                                                                  |
| `PHP_MEMORY_LIMIT`                             | `memory_limit`                             | `256M`                                                                                                                                |
| `PHP_OPCACHE_CLI_ENABLE`                       | `opcache.enable_cli`                       | `0`                                                                                                                                   |
| `PHP_OPCACHE_ENABLE`                           | `opcache.enable`                           | `1`                                                                                                                                   |
| `PHP_OPCACHE_ERROR_LOG`                        | `opcache.error_log`                        | `/proc/self/fd/2`                                                                                                                     |
| `PHP_OPCACHE_INTERNED_STRINGS_BUFFER`          | `opcache.interned_strings_buffer`          | `32`                                                                                                                                  |
| `PHP_OPCACHE_JIT_BUFFER_SIZE`                  | `opcache.jit_buffer_size`                  | `0`                                                                                                                                   |
| `PHP_OPCACHE_LOG_VERBOSITY_LEVEL`              | `opcache.log_verbosity_level`              | `1`                                                                                                                                   |
| `PHP_OPCACHE_MAX_ACCELERATED_FILES`            | `opcache.max_accelerated_files`            | `32531`                                                                                                                               |
| `PHP_OPCACHE_MEMORY_CONSUMPTION`               | `opcache.memory_consumption`               | `256`                                                                                                                                 |
| `PHP_OPCACHE_PRELOAD_PATH`                     | `opcache.preload`                          | _(empty)_                                                                                                                             |
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS`              | `opcache.validate_timestamps`              | `1`                                                                                                                                   |
| `PHP_OPENSSL_CAFILE`                           | `openssl.cafile`                           | _(empty)_                                                                                                                             |
| `PHP_OPENSSL_CAPATH`                           | `openssl.capath`                           | _(empty)_                                                                                                                             |
| `PHP_PM_MAX_CHILDREN`                          | `pm.max_children`                          | `5`                                                                                                                                   |
| `PHP_PM_MAX_REQUESTS`                          | `pm.max_requests`                          | `0`                                                                                                                                   |
| `PHP_PM_MAX_SPARE_SERVERS`                     | `pm.max_spare_servers`                     | `3`                                                                                                                                   |
| `PHP_PM_MAX_SPAWN_RATE`                        | `pm.max_spawn_rate` (PHP 8.5+)             | `32`                                                                                                                                  |
| `PHP_PM_MIN_SPARE_SERVERS`                     | `pm.min_spare_servers`                     | `1`                                                                                                                                   |
| `PHP_PM_START_SERVERS`                         | `pm.start_servers`                         | `2`                                                                                                                                   |
| `PHP_POST_MAX_SIZE`                            | `post_max_size`                            | `0M`                                                                                                                                  |
| `PHP_REGISTER_ARGC_ARGV`                       | `register_argc_argv`                       | `0`                                                                                                                                   |
| `PHP_SESSION_COOKIE_PARTITIONED`               | `session.cookie_partitioned` (PHP 8.5+)    | `0`                                                                                                                                   |
| `PHP_SESSION_COOKIE_SAMESITE`                  | `session.cookie_samesite`                  | _(empty)_                                                                                                                             |
| `PHP_SESSION_COOKIE_SECURE`                    | `session.cookie_secure`                    | _(empty)_                                                                                                                             |
| `PHP_SESSION_SAVE_HANDLER`                     | `session.save_handler`                     | `files`                                                                                                                               |
| `PHP_SESSION_SAVE_PATH`                        | `session.save_path`                        | `/tmp`                                                                                                                                |
| `PHP_SLOW_LOG`                                 | `slowlog`                                  | `/proc/self/fd/2`                                                                                                                     |
| `PHP_UPLOAD_MAX_FILESIZE`                      | `upload_max_filesize`                      | `20M`                                                                                                                                 |
| `PHP_VARIABLES_ORDER`                          | `variables_order`                          | `GPCS`                                                                                                                                |
| `PHP_ZEND_MAX_ALLOWED_STACK_SIZE`              | `zend.max_allowed_stack_size`              | `0`                                                                                                                                   |

These images deliberately ship no php-fpm status or ping endpoint. Need one? Mount your own `www.conf`, or send a PR.

## Container environment

Cron jobs do not inherit the container environment. `docker-entrypoint` therefore exports it into `/etc/environment.app`
and `cron-cmd` sources that file.

| Variable                       | Meaning                                                                  | Default                                          |
| ------------------------------ | ------------------------------------------------------------------------ | ------------------------------------------------ |
| `DOCKER_APP_EXCLUDED_ENV_VARS` | Vars excluded from the `/etc/environment.app` export (regex alternation) | `HOME\|LOGNAME\|OLDPWD\|PWD\|SHELL\|SHLVL\|TERM` |
