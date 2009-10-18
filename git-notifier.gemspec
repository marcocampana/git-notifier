# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git-notifier}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marco Campana"]
  s.date = %q{2009-10-13}
  s.description = %q{ git-notifier is a gem for Mac Os that allows you to watch one or more git repositories and receive a growl notification when a change is committed}
  s.email = %q{m.campana@gmail.com}
  s.executables = ["git-notifier"]
  s.homepage = %q{http://github.com/marcocampana/git-notifier}
  # s.has_rdoc = false
  # s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  # s.require_paths = ["lib"]
  s.rubyforge_project = %q{git-notifier}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{ git-notifier is a gem for Mac Os that allows you to watch one or more git repositories and receive a growl notification when a change is committed }

  # if s.respond_to? :specification_version then
  #   current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  #   s.specification_version = 2
  # 
  #   if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
  #     s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
  #     s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #   else
  #     s.add_dependency(%q<mime-types>, [">= 1.15"])
  #     s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #   end
  # else
  #   s.add_dependency(%q<mime-types>, [">= 1.15"])
  #   s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  # end
end