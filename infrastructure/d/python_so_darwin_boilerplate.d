extern(C) { 

void gc_init(); 
void gc_term(); 
void _moduleCtor(); 
void _moduleDtor(); 
void _moduleUnitTests(); 


version(GNU) { pragma(attribute, constructor) }
void _init() { 
    gc_init(); 
    //_moduleCtor(); // XXX PI does not work here... moded in PydMain 
    //_moduleUnitTests(); // idem 
} 

version(GNU) { pragma(attribute, destructor) }
void _fini() { 
   _moduleDtor(); 
   gc_term(); 
} 

}
