


include struct
  external f : int -> int -> int = "add" [@@bs.val]   
end  [@@bs.send: core_type] [@@bs.module "fs"]

include struct
  external basename : string -> string = "" 
  external basename_ext : string -> string -> string  =  "basename" 
  external delimiter : string = "" 
  external dirname : string -> string = "" 
  external dirname_ext : string -> string -> string = "dirname" 
end [@@bs.module "path"]

include struct 
  external width : int = "" 
  external hight : int = ""
  external length : int = ""
  external cool : string = ""    
end [@@bs.set:table]


include struct
  external concat : 'self_type -> 'self_type = ""
  external append : 'a u -> 'a -> 'a u = "concat"
end [@@bs.send: 'a u as 'self_type]  

include struct
  external readdirSync : string -> string = ""
  external readlinkSync : string -> string array = ""
end [@@bs.module "fs"] [@@bs.group]   
