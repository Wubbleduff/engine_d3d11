//    
//    
//    ////////////////////////////////////////////////////////////////////////////////
//    //
//    // cl build.c && build.exe
//    //
//    ////////////////////////////////////////////////////////////////////////////////
//    
//    const char* program_name;
//    

struct Build
{
    const char* name;
    const char* cc_cmd;
    int num_cc_flags;
    const char* cc_flags[256];

    const char* link_cmd;
    int num_link_flags;
    const char* link_flags[256];
};

#define ARRAY_INIT(TYPE, NAME, ...) \
.num_##NAME = (sizeof( (TYPE[]) { __VA_ARGS__ } ) / sizeof(TYPE)), \
.NAME = { \
    __VA_ARGS__ \
}

struct Build build[] =
{
    {
        .name = "clang",

        .cc_cmd = "clang-cl",
        ARRAY_INIT(
            const char*,
            cc_flags,
            "/c",
            "/W4",
            "/WX",
            "/EHsc",
            "/std:c17",
            // Avoid C runtime library
            // https://hero.handmade.network/forums/code-discussion/t/94-guide_-_how_to_avoid_c_c++_runtime_on_windows
            "/GS-",
            "/Gs9999999",
            "/nologo",
        ),

        .link_cmd = "lld-link",
        ARRAY_INIT(
            const char*,
            link_flags,
            "/NODEFAULTLIB",
            "/STACK:0x100000,0x100000",
            "/SUBSYSTEM:WINDOWS",
            "/MACHINE:X64",
        ),
    },
};


#include <stdio.h>

int main()
{
    
    for(int i = 0; i < build[0].num_cc_flags; i++)
    {
        printf("%s\n", build[0].cc_flags[i]);
    }
}
