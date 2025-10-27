
#include "game_state.h"
#include "input.h"

void init_game_state(struct GameState* game_state)
{
    game_state->cam_pos_x = 8.0f;
    game_state->cam_pos_y = 8.0f;
    game_state->cam_pos_z = 8.0f;

    game_state->cam_forward_x = -0.57735f;
    game_state->cam_forward_y = -0.57735f;
    game_state->cam_forward_z = -0.57735f;

    game_state->num_cubes = 0;
}

void update_game_state(struct GameState* game_state, const struct GameState* prev_game_state)
{
    f32 cam_pos_x = prev_game_state->cam_pos_x;
    f32 cam_pos_y = prev_game_state->cam_pos_y;
    f32 cam_pos_z = prev_game_state->cam_pos_z;

    cam_pos_x += (f32)is_keyboard_key_down(KB_D) * 0.1f;
    cam_pos_x -= (f32)is_keyboard_key_down(KB_A) * 0.1f;
    cam_pos_y += (f32)is_keyboard_key_down(KB_SPACE) * 0.1f;
    cam_pos_y -= (f32)is_keyboard_key_down(KB_LCTRL) * 0.1f;
    cam_pos_z += (f32)is_keyboard_key_down(KB_S) * 0.1f;
    cam_pos_z -= (f32)is_keyboard_key_down(KB_W) * 0.1f;

    game_state->num_cubes = 3;
    {
        game_state->cube_pos_x[0] = 2.0f;
        game_state->cube_pos_y[0] = 0.0f;
        game_state->cube_pos_z[0] = 0.0f;
    }
    {
        game_state->cube_pos_x[1] = 0.0f;
        game_state->cube_pos_y[1] = 2.0f;
        game_state->cube_pos_z[1] = 0.0f;
    }
    {
        game_state->cube_pos_x[2] = 0.0f;
        game_state->cube_pos_y[2] = 0.0f;
        game_state->cube_pos_z[2] = 2.0f;
    }

    game_state->cam_pos_x = cam_pos_x;
    game_state->cam_pos_y = cam_pos_y;
    game_state->cam_pos_z = cam_pos_z;

    game_state->cam_forward_x = prev_game_state->cam_forward_x;
    game_state->cam_forward_y = prev_game_state->cam_forward_y;
    game_state->cam_forward_z = prev_game_state->cam_forward_z;
}
