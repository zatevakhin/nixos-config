{...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";

    image = builtins.fetchurl {
      url = "https://images8.alphacoders.com/128/1285341.jpg";
      sha256 = "199ly8yyj8v72v6qvwp04zdhm51fcxb0qxli5lg2fr4zwiz2hm6f";
    };
    imageScalingMode = "fill";
  };

  # TODO: Add fonts
}
