#!/usr/bin/python3
import csv
import sys


def main(fullFile, reducedFile):
    reader = csv.reader(fullFile, dialect=csv.unix_dialect)
    writer = csv.writer(reducedFile, dialect=csv.unix_dialect)

    nodes = []
    domains = []
    connectors = []
    for row in reader:
        if row[0] == "N":
            nodes.append(row)
        if row[0] == "C":
            connectors.append(row)
        if row[0] == "D":
            domains.append(row)
        if row[0] == "SVG":
            writer.writerow(row)
    finished = False
    while not finished:
        leafNodeNames = [node[1] for node in nodes]
        for node in nodes:
            if node[3] in leafNodeNames:
                leafNodeNames.remove(node[3])
        nodesToRemove = []
        for node in nodes:
            if node[1] in leafNodeNames:
                if node[5] != "":
                    nodesToRemove.append(node)
        for node in nodesToRemove:
            nodes.remove(node)
        finished = len(nodesToRemove) == 0
    nodeNames = [node[1] for node in nodes]
    connectorsToRemove, domainsToRemove = [], []
    for connector in connectors:
        if (connector[2] not in nodeNames) or (connector[4] not in nodeNames):
            connectorsToRemove.append(connector)
    for connector in connectorsToRemove:
        connectors.remove(connector)
    for domain in domains:
        if domain[1] not in nodeNames:
            domainsToRemove.append(domain)
    for domain in domainsToRemove:
        domains.remove(domain)
    for node in nodes:
        writer.writerow(node)
    for connector in connectors:
        writer.writerow(connector)
    for domain in domains:
        writer.writerow(domain)


if __name__ == '__main__':
    if "--help" in sys.argv or "-h" in sys.argv:
        print(
"""Script to remove end of life distributions.
Parses a complete list of distributions and writes only those active in a
separate file.
===============================================================================
Usage:
./removeEOL.py [sourceFile targetFile]

  sourceFile    File with the complete list of distributions, defaults to 
                'gldt.csv'
  targetFile    File to write the generated list to, defaults to
                'noEOLgldt.csv'"""
        )
        sys.exit(0)
    sourceFile = 'gldt.csv'
    targetFile = 'noEOLgldt.csv'
    if len(sys.argv) == 3:
        sourceFile = sys.argv[1]
        targetFile = sys.argv[2]
    with open(sourceFile, 'r') as fullFile, open(targetFile, 'w') as reducedFile:
        main(fullFile, reducedFile)
