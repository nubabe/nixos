_:

{

  den.aspects.oh-my-posh.homeManager = {
    programs.oh-my-posh = {
      enable = true;
      settings = {
        "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
        final_space = true;
        version = 4;
        async = true;
        blocks = [
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "text";
                style = "plain";
                foreground = "green";
                template = "{{ .HostName }}";
                foreground_templates = [
                  "{{if .Root}}yellow{{end}}"
                ];
              }
              {
                type = "path";
                style = "plain";
                foreground = "blue";
                properties.style = "full";
              }
              {
                type = "git";
                style = "plain";
                foreground = "white";
                template = "{{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} {{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}";
                properties = {
                  branch_icon = "";
                  commit_icon = "@";
                  fetch_status = true;
                };
              }
            ];
          }
          {
            type = "rprompt";
            alignment = "right";
            overflow = "hidden";
            segments = [
              {
                type = "executiontime";
                style = "plain";
                foreground = "yellow";
                template = "{{ .FormattedMs }}";
                properties.threshold = 500;
              }
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "text";
                style = "plain";
                foreground_templates = [
                  "{{if gt .Code 0}}red{{end}}"
                  "{{if eq .Code 0}}blue{{end}}"
                ];
                template = "❯";
              }
            ];
          }
        ];
        transient_prompt = {
          foreground_templates = [
            "{{if gt .Code 0}}red{{end}}"
            "{{if eq .Code 0}}blue{{end}}"
          ];
          template = "❯ ";
        };
        secondary_prompt = {
          foreground = "blue";
          template = "❯❯ ";
        };
      };
    };
  };

}
