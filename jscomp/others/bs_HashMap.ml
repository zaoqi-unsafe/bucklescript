(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)
(**  Adapted by Authors of BuckleScript 2017                           *)
type ('a, 'b,'id) t0 = ('a,'b,'id) Bs_internalBuckets.t0 =
  {
    mutable size: int;                        (* number of entries *)
    mutable buckets: ('a, 'b) Bs_internalBuckets.bucketlist array;  (* the buckets *)
    initial_size: int;                        (* initial array size *)
  }


type ('a,'b) buckets = ('a,'b) Bs_internalBuckets.buckets 

type ('a,'b,'id) t = {
  dict : ('a, 'id) Bs_Hash.t;
  data : ('a,'b,'id) t0;
}


let rec insert_bucket ~hash ~h_buckets ~ndata_tail h old_bucket = 
  match Bs_internalBuckets.toOpt old_bucket with 
  | None -> ()
  | Some cell ->
    let nidx = (Bs_Hash.getHash hash) (Bs_internalBuckets.key cell) [@bs] land (Array.length h_buckets - 1) in 
    let v = Bs_internalBuckets.return cell in 
    begin match Bs_internalBuckets.toOpt (Bs_Array.unsafe_get ndata_tail nidx) with
      | None -> 
        Bs_Array.unsafe_set h_buckets nidx  v
      | Some tail ->
        Bs_internalBuckets.nextSet tail v  (* cell put at the end *)            
    end;          
    Bs_Array.unsafe_set ndata_tail nidx  v;
    insert_bucket ~hash ~h_buckets ~ndata_tail h (Bs_internalBuckets.next cell)


let resize ~hash h =
  let odata = h.buckets in
  let osize = Array.length odata in
  let nsize = osize * 2 in
  if nsize >= osize then begin (* no overflow *)
    let h_buckets = Bs_internalBuckets.makeSize nsize  in
    let ndata_tail = Bs_internalBuckets.makeSize nsize  in (* keep track of tail *)
    h.buckets <- h_buckets;          (* so that indexfun sees the new bucket count *)
    for i = 0 to osize - 1 do
      insert_bucket ~hash ~h_buckets ~ndata_tail h (Bs_Array.unsafe_get odata i)
    done;
    for i = 0 to nsize - 1 do
      match Bs_internalBuckets.toOpt (Bs_Array.unsafe_get ndata_tail i) with
      | None -> ()
      | Some tail -> Bs_internalBuckets.nextSet tail Bs_internalBuckets.emptyOpt
    done
  end


let add0 ~hash h key value =
  let h_buckets = h.buckets in  
  let h_buckets_lenth = Array.length h_buckets in 
  let i = (Bs_Hash.getHash hash) key [@bs] land (h_buckets_lenth - 1) in 
  let bucket = 
    Bs_internalBuckets.newBuckets ~key ~value ~next:(Bs_Array.unsafe_get h_buckets i) in  
  Bs_Array.unsafe_set h_buckets i  (Bs_internalBuckets.return bucket);
  let h_new_size = h.size + 1 in 
  h.size <- h_new_size;
  if h_new_size > h_buckets_lenth lsl 1 then resize ~hash  h


let rec remove_bucket ~eq h h_buckets  i key prec buckets =
  match Bs_internalBuckets.toOpt buckets with
  | None -> ()
  | Some cell ->
    let cell_next = Bs_internalBuckets.next cell in 
    if (Bs_Hash.getEq eq) (Bs_internalBuckets.key cell) key [@bs]
    then 
      begin
        (match Bs_internalBuckets.toOpt prec with
         | None -> Bs_Array.unsafe_set h_buckets i  cell_next
         | Some c -> Bs_internalBuckets.nextSet c cell_next);
        h.size <- h.size - 1;        
      end
    else remove_bucket ~eq h h_buckets i key buckets cell_next

let remove0 ~hash ~eq h key =  
  let h_buckets = h.buckets in 
  let i = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in  
  remove_bucket ~eq h h_buckets i key Bs_internalBuckets.emptyOpt (Bs_Array.unsafe_get h_buckets i)

let rec removeAllBuckets ~eq h h_buckets  i key prec buckets =
  match Bs_internalBuckets.toOpt buckets with
  | None -> ()
  | Some cell ->
    let cell_next = Bs_internalBuckets.next cell in 
    if (Bs_Hash.getEq eq) (Bs_internalBuckets.key cell) key [@bs]
    then 
      begin
        (match Bs_internalBuckets.toOpt prec with
         | None -> Bs_Array.unsafe_set h_buckets i  cell_next
         | Some c -> Bs_internalBuckets.nextSet c cell_next);
        h.size <- h.size - 1;        
      end;
    removeAllBuckets ~eq h h_buckets i key buckets cell_next

let removeAll0 ~hash ~eq h key =
  let h_buckets = h.buckets in 
  let i = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in  
  removeAllBuckets ~eq h h_buckets i key Bs_internalBuckets.emptyOpt (Bs_Array.unsafe_get h_buckets i)


let rec find_rec ~eq key buckets = 
  match Bs_internalBuckets.toOpt buckets with 
  | None ->
    None
  | Some cell ->
    if (Bs_Hash.getEq eq) key (Bs_internalBuckets.key cell) [@bs] then Some (Bs_internalBuckets.value cell)
    else find_rec ~eq key  (Bs_internalBuckets.next cell)

let findOpt0 ~hash ~eq h key =
  let h_buckets = h.buckets in 
  let nid = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  match Bs_internalBuckets.toOpt @@ Bs_Array.unsafe_get h_buckets nid with
  | None -> None
  | Some cell1  ->
    if (Bs_Hash.getEq eq) key (Bs_internalBuckets.key cell1) [@bs] then 
      Some  (Bs_internalBuckets.value cell1)
    else
      match Bs_internalBuckets.toOpt (Bs_internalBuckets.next  cell1) with
      | None -> None
      | Some cell2 ->
        if (Bs_Hash.getEq eq) key 
          (Bs_internalBuckets.key cell2) [@bs] then 
            Some (Bs_internalBuckets.value cell2) else
          match Bs_internalBuckets.toOpt (Bs_internalBuckets.next cell2) with
          | None -> None
          | Some cell3 ->
            if (Bs_Hash.getEq eq) key 
              (Bs_internalBuckets.key cell3) [@bs] then 
              Some (Bs_internalBuckets.value cell3)
            else 
              find_rec ~eq key (Bs_internalBuckets.next cell3)


let findAll0 ~hash ~eq h key =
  let rec find_in_bucket buckets = 
    match Bs_internalBuckets.toOpt buckets with 
    | None ->
      []
    | Some cell ->
      if (Bs_Hash.getEq eq) 
        (Bs_internalBuckets.key cell) key [@bs]
      then (Bs_internalBuckets.value cell) :: find_in_bucket (Bs_internalBuckets.next cell)
      else find_in_bucket (Bs_internalBuckets.next cell)  in
  let h_buckets = h.buckets in     
  let nid = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  find_in_bucket (Bs_Array.unsafe_get h_buckets nid)

let rec replace_bucket ~eq  key info buckets = 
  match Bs_internalBuckets.toOpt buckets with 
  | None ->
    true
  | Some cell ->
    if (Bs_Hash.getEq eq) (Bs_internalBuckets.key cell) key [@bs]
    then
      begin
        Bs_internalBuckets.keySet cell key;
        Bs_internalBuckets.valueSet cell info;
        false
      end
    else
      replace_bucket ~eq key info (Bs_internalBuckets.next cell)

let replace0 ~hash ~eq  h key info =
  let h_buckets = h.buckets in 
  let i = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  let l = Array.unsafe_get h_buckets i in  
  if replace_bucket ~eq key info l then begin
    Bs_Array.unsafe_set h_buckets i (Bs_internalBuckets.return 
                                       (Bs_internalBuckets.newBuckets ~key ~value:info ~next:l));
    h.size <- h.size + 1;
    if h.size > Array.length h.buckets lsl 1 then resize ~hash h
  end 

let rec mem_in_bucket ~eq key buckets = 
  match Bs_internalBuckets.toOpt buckets with 
  | None ->
    false
  | Some cell ->
    (Bs_Hash.getEq eq) 
    (Bs_internalBuckets.key cell) key [@bs] || 
    mem_in_bucket ~eq key (Bs_internalBuckets.next cell)

let mem0 ~hash ~eq h key =
  let h_buckets = h.buckets in 
  let nid = (Bs_Hash.getHash hash) key [@bs] land (Array.length h_buckets - 1) in 
  mem_in_bucket ~eq key (Bs_Array.unsafe_get h_buckets nid)


let create0 = Bs_internalBuckets.create0
let clear0 = Bs_internalBuckets.clear0
let reset0 = Bs_internalBuckets.reset0
let length0 = Bs_internalBuckets.length0
let iter0 = Bs_internalBuckets.iter0
let fold0 = Bs_internalBuckets.fold0
let logStats0 = Bs_internalBuckets.logStats0
let filterMapInplace0 = Bs_internalBuckets.filterMapInplace0

(*  Wrapper  *)
let create dict initialize_size = 
  { data  = create0 initialize_size  ;
    dict }
let clear h = clear0 h.data
let reset h = reset0 h.data
let length h = length0 h.data                  
let iter f h = iter0 f h.data
let fold f h init = fold0 f h.data init 
let logStats h = logStats0 h.data

let add (type a) (type b ) (type id) (h : (a,b,id) t) (key:a) (info:b) = 
  let module M = (val  h.dict) in 
  add0 ~hash:M.hash h.data key info 

let remove (type a) (type b) (type id) (h : (a,b,id) t) (key : a) = 
  let module M = (val h.dict) in   
  remove0 ~hash:M.hash ~eq:M.eq h.data key 

let removeAll (type a) (type b) (type id) (h : (a,b,id) t) (key : a) = 
  let module M = (val h.dict) in   
  removeAll0 ~hash:M.hash ~eq:M.eq h.data key 

let findOpt (type a) (type b) (type id) (h : (a,b,id) t) (key : a) =           
  let module M = (val h.dict) in   
  findOpt0 ~hash:M.hash ~eq:M.eq h.data key 

let findAll (type a) (type b) (type id) (h : (a,b,id) t) (key : a) =           
  let module M = (val h.dict) in   
  findAll0 ~hash:M.hash ~eq:M.eq h.data key   

let replace (type a) (type b) (type id)  (h : (a,b,id) t) (key : a) (info : b) =
  let module M = (val h.dict) in 
  replace0 ~hash:M.hash ~eq:M.eq h.data key info

let mem (type a) (type b) (type id) (h : (a,b,id) t) (key : a) =           
  let module M = (val h.dict) in   
  mem0 ~hash:M.hash ~eq:M.eq h.data key   

let filterMapInplace  f h =
  filterMapInplace0 f h.data
