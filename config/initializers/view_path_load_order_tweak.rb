blacklight_path = ApplicationController.view_paths.select { |x| x.to_s =~ /blacklight/ }.first
blacklight_idx = ApplicationController.view_paths.find_index(blacklight_path)

hydra_path = ApplicationController.view_paths.select { |x| x.to_s =~ /hydra-head/ }.first
hydra_idx = ApplicationController.view_paths.find_index(hydra_path)

if blacklight_idx > hydra_idx
 ApplicationController.view_paths.paths.slice!(blacklight_idx)
 ApplicationController.view_paths.insert(hydra_idx, blacklight_path)
end
