require 'typesafe_enum'

class LinkType < TypesafeEnum::Base
  new :EXTERNAL
  new :FILE
  new :FRAGMENT
  new :LOCAL
  new :MAILTO
  new :UNKNOWN
end

class LabelSource < TypesafeEnum::Base
  new :FROM_PAGE_TITLE
  new :FROM_EXPLICIT_LABEL
  new :FROM_IMPLICIT_LABEL
end

class Hyphenation < TypesafeEnum::Base
  new :NONE
  new :SHY
  new :WBR
end
