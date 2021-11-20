#!/usr/bin/python

import argparse
# from colorama import init, Fore, Back, Style
# init(autoreset=True)
from termcolor import colored

parser = argparse.ArgumentParser(description='Addition to perl game.pl. Updates and\or prints scoreboard.')
parser.add_argument('-s', '--save', dest='result', action='store', nargs="+", help='Save given result: nick score time')
parser.add_argument('-p', '--print', action='store_true', help='Print the scoreboard.')

args = parser.parse_args()
# print(args)

def comparator(e):
  return int(e[1]), int(e[2])

def save_result(result):
  # print(result)
  nick = result[0]
  score = result[1]
  time = result[2]
  scoreboard_file = open('scoreboard.txt', 'a')
  scoreboard_file.write(" ".join([nick, score, time, '\n']))

def print_scoreboard(max):
  try:
    scoreboard_file = open('scoreboard.txt', 'r')
  except FileNotFoundError:
    print('The scoreboard yet not exists!')
  else:
    lines = scoreboard_file.readlines()
    lines = [word for line in lines for word in line.split()]
    lines = [lines[x:x+3] for x in range(0, len(lines), 3)]   
    count = len(lines)

    if(result):
      lines[count-1].append("new")

    lines.sort(reverse=False, key=comparator)

    for i in range(0, count):
      rank = i+1
      lines[i] = [rank] + lines[i]

    # print(lines)
    new_result = None
    if(result):
      new_result = [s for s in lines if "new" in s][0]

    max = max or count
    if(count < 11):
      max = count
    if(new_result and max != count):
      max = max + 2
    # print(max)
    
    print("{: >20} {: >20} {: >20} {: >20} {: >20}\n".format(*["No.", "Nick", "Score", "Time", ""]))
    for i in range(0, max):
      line = lines[i]
      if(line[-1] == "new"):
        # print(Fore.RED + "{: >20} {: >20} {: >20} {: >20} {: >20}".format(*line))
        print(colored("{: >20} {: >20} {: >20} {: >20} {: >20}".format(*line), 'red'))
      else:
        line.append('')
        print("{: >20} {: >20} {: >20} {: >20} {: >20}".format(*line))
    
    if(max < count and new_result[0] > max):
      print("{: >20} {: >20} {: >20} {: >20} {: >20}".format(*["-", "-", "-", "-", ""]))
      print(colored("{: >20} {: >20} {: >20} {: >20} {: >20}".format(*new_result), 'red'))

    if(max < count and new_result[0] != count ):
      line = lines[-1]
      line.append('')
      print("{: >20} {: >20} {: >20} {: >20} {: >20}".format(*["-", "-", "-", "-", ""]))
      print("{: >20} {: >20} {: >20} {: >20} {: >20}".format(*line))



result = vars(args)['result']
if(result):
  save_result(result)

print_score = vars(args)['print']
if (print_score):
  if (result):
    print_scoreboard(6)
  else:
    print_scoreboard(0)
  