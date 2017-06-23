# frozen_string_literal: true

resource_name :assertion_error
default_action :nothing

property :message, String, name_property: true

action :raise do
  raise message
end
