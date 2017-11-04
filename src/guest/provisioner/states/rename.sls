how_to_call_everything_at_once:
  module.run:
    - system.set_computer_name:
        - name: {{ salt['environ.get']('HOST_NAME') }}