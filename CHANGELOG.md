# Changelog

## 1.0.27
- cleanup Time.ensure

## 1.0.26
- add handling of milliseconds to Time.ensure

## 1.0.25
- have to use a string comparison for final result `1 != "1"`

## 1.0.24
- make sure that a string that starts with a number doesn't find an integer primary key record

## 1.0.23
- forgot version boundry on ActiveSupport

## 1.0.22
- support Rails 6+

## 1.0.21
- properly handle empty strings

## 1.0.20
- support Rails 6

## 1.0.19
- always use Time.zone when ensure times or dates
