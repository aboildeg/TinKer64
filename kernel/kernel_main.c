#include <stdint.h>
#include <stddef.h>
#include <limine.h>

static volatile struct limine_terminal_request terminal_request = 
{
    .id = LIMINE_TERMINAL_REQUEST,
    .revision = 0
};

static void hlt(void)
{
    for (;;)
    {
        __asm__("hlt");
    }
}

void _start(void)
{
    if (terminal_request.response == NULL || terminal_request.response->terminal_count < 1) // If terminal not available, then hang
    {
        hlt();
    }

    struct limine_terminal *term = terminal_request.response->terminals[0];
    terminal_request.response->write(term, "Hello World", 11);

    hlt();
}