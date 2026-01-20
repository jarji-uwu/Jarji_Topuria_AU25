"""
Module for preparing inverted indexes based on uploaded documents
"""

import sys
import json
import re
from argparse import ArgumentParser, ArgumentTypeError, FileType
from io import TextIOWrapper
from typing import Dict, List

DEFAULT_PATH_TO_STORE_INVERTED_INDEX = "inverted.index"


class EncodedFileType(FileType):
    """File encoder"""

    def __call__(self, string):
        if string == "-":
            if "r" in self._mode:
                return TextIOWrapper(sys.stdin.buffer, encoding=self._encoding)
            if "w" in self._mode:
                return TextIOWrapper(sys.stdout.buffer, encoding=self._encoding)
            raise ValueError(f'argument "-" with mode {self._mode!r}')

        try:
            return open(string, self._mode, self._bufsize, self._encoding, self._errors)
        except OSError as exception:
            raise ArgumentTypeError(f"can't open '{string}': {exception}")

    def print_encoder(self):
        print(self._encoding)


class InvertedIndex:
    """
    This module is necessary to extract inverted indexes from documents.
    """

    def __init__(self, words_ids: Dict[str, List[int]]):
        self.words_ids = words_ids

    def query(self, words: List[str]) -> List[int]:
        result = None
        for word in words:
            docs = set(self.words_ids.get(word, []))
            result = docs if result is None else result & docs
        return sorted(result) if result else []

    def dump(self, filepath: str) -> None:
        with open(filepath, "w", encoding="utf-8") as file:
            json.dump(self.words_ids, file)

    @classmethod
    def load(cls, filepath: str):
        with open(filepath, encoding="utf-8") as file:
            data = json.load(file)
        return cls(data)


def load_documents(filepath: str) -> Dict[int, str]:
    documents = {}
    with open(filepath, encoding="utf-8") as file:
        for line in file:
            doc_id, content = line.lower().split("\t", 1)
            documents[int(doc_id)] = content
    return documents


def build_inverted_index(documents: Dict[int, str]) -> InvertedIndex:
    index = {}
    for doc_id, text in documents.items():
        words = re.split(r"\W+", text)
        for word in set(words):
            if word:
                index.setdefault(word, []).append(doc_id)
    return InvertedIndex(index)


def callback_build(arguments) -> None:
    return process_build(arguments.dataset, arguments.output)


def process_build(dataset, output) -> None:
    documents = load_documents(dataset)
    inverted_index = build_inverted_index(documents)
    inverted_index.dump(output)


def callback_query(arguments) -> None:
    process_query(arguments.query, arguments.index)


def process_query(queries, index) -> None:
    inverted_index = InvertedIndex.load(index)

    if hasattr(queries, "read"):
        queries = queries.read().splitlines()

    for query in queries:
        if isinstance(query, str):
            query = query.strip().split()

        doc_indexes = ",".join(str(value) for value in inverted_index.query(query))
        print(doc_indexes)


def setup_subparsers(parser) -> None:
    subparser = parser.add_subparsers(dest="command")

    build_parser = subparser.add_parser("build")
    build_parser.add_argument("-d", "--dataset", required=True)
    build_parser.add_argument(
        "-o", "--output", default=DEFAULT_PATH_TO_STORE_INVERTED_INDEX
    )
    build_parser.set_defaults(callback=callback_build)

    query_parser = subparser.add_parser("query")
    query_parser.add_argument(
        "--index", default=DEFAULT_PATH_TO_STORE_INVERTED_INDEX
    )

    query_group = query_parser.add_mutually_exclusive_group(required=True)
    query_group.add_argument(
        "-q", "--query", dest="query", action="append", nargs="+"
    )
    query_group.add_argument(
        "--query_from_file",
        dest="query",
        type=EncodedFileType("r", encoding="utf-8"),
    )

    query_parser.set_defaults(callback=callback_query)


def main():
    parser = ArgumentParser(
        description="Inverted Index CLI is need to load, build, process query inverted index"
    )
    setup_subparsers(parser)
    arguments = parser.parse_args()
    arguments.callback(arguments)


if __name__ == "__main__":
    main()
