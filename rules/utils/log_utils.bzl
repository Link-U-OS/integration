# Copyright (c) 2025, AgiBot Inc.
# All rights reserved.

def agibot_fail(error_msg, cause_msg, solution_msg):
    """
    SDK Log with severity 'ERROR', msg = 'error + cause + solution', a warpper for 'fail' function
    usage:
        agibot_fail("Houston, we have a xxx error", "xxx_cause", "xxx_solution")
    """
    indentation = " " * 4
    error_msg = indentation + error_msg
    cause_msg = indentation + cause_msg.replace("\n", "\n" + indentation)
    solution_msg = indentation + solution_msg.replace("\n", "\n" + indentation)
    red_txt = "\033[1;31m"
    green_txt = "\033[1;32m"
    yellow_txt = "\033[1;33m"
    color_clear = "\033[0m"
    msg = red_txt \
          + "\n" + error_msg + color_clear \
          + yellow_txt + "\nCause:\n" + color_clear + cause_msg \
          + green_txt + "\nSolution:\n" + color_clear + solution_msg
    fail(msg)
