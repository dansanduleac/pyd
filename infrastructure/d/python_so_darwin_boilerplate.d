extern(C) { 

extern (C) void gc_init(); 
extern (C) void gc_term(); 
extern (C) void _moduleCtor(); 
extern (C) void _moduleDtor(); 
extern (C) void _moduleUnitTests(); 


pragma(attribute, constructor) void _init() { 
    gc_init(); 
    //_moduleCtor(); // XXX PI does not work here... moded in PydMain 
    //_moduleUnitTests(); // idem 
} 

pragma(attribute, destructor) void _fini() { 
   _moduleDtor(); 
   gc_term(); 
} 

}
