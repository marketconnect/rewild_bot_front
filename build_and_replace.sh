#!/bin/bash

flutter build web
dart run tool/replace_base_tag.dart
