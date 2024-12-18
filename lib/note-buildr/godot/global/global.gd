extends Node

var section_seaking_connection : Section
var section_connection_candidate : Section
var hovered_to_selected_nnode := false
var grabbed_io_nnode: NNodeIO = null
var io_connection_candidate: NNodeIO = null
var grabbed_io_parent_nnode: NNode
var grabbed_io_input := false
