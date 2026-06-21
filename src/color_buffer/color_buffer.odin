package color_buffer

import "core:mem"
import "core:log"

color_buffer: []u32 = nil

init_color_buffer :: proc(buffer_size: u32) -> (err: mem.Allocator_Error) {
    when ODIN_DEBUG {
        log.info("Start color buffer initialization.")
    }

    color_buffer, err = make([]u32, buffer_size)

    if ODIN_DEBUG {
        if err != nil {
            log.fatal("Color buffer was NOT initialized.")
        }   
        else {
            size := size_of(color_buffer)
            log.info("Color buffer initialized. Size %d bytes.", size)
        }
    }    

    return err
}

delete_color_buffer :: proc() {
    delete(color_buffer)
    
    when ODIN_DEBUG {
        log.info("Color buffer destroyed")
    }
}