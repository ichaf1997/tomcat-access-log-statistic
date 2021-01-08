import os
import re
import json
import argparse
from pathlib import Path
from datetime import datetime
from collections import Counter

class Summary(object):
    """汇总文件统计结果，并输出保存成json文件"""

    def __init__(self, files_tuple, save_dir=os.path.dirname(__file__)):
        self._files_tuple = files_tuple
        self._save_dir = save_dir
        self.is_valid(self._files_tuple, self._save_dir)

    @staticmethod
    def is_valid(files_tuple, save_dir):
        assert (files_tuple), '汇总输入文件为空'
        for file in files_tuple:
            if not os.path.isfile(file):
                raise FileNotFoundError(f'No such file or directory ({file})')
        if not os.path.isdir(save_dir):
            raise FileNotFoundError(f'No such file or directory ({save_dir})')

    def load_data(self):
        """返回文件汇总统计所得Counter"""
        data = Counter()
        for files in self._files_tuple:
            try:
                with open(files, mode='r', encoding='utf-8') as f:
                    text_list = list(filter(lambda line: re.match(r'^[1-9]', line), f.read().split('\n')))
                    text_dict = { record.split()[-1]: int(record.split()[0]) for record in text_list if not record.startswith('#') }
                    data.update(text_dict)
            except:
                raise 
        self._data = data
        return data

    def save_as_json(self, flags=None):
        """将Counter输出到json文件"""
        time_obj = datetime.now()
        file_name = 'summary.' + datetime.strftime(time_obj, '%Y-%m-%d-%H%M%S') + '.json'
        json_data = {
            'metadata': {
            'time': datetime.strftime(time_obj, '%Y-%m-%d-%H:%M:%S'),
            'summarized_files': list(map(lambda item: str(item), self._files_tuple)),
            'flags': flags
            },
            'spec': self._data        
        }
        try:
            with open(os.path.join(self._save_dir, file_name), mode='w', encoding='utf-8') as f:
                json.dump(json_data, f, ensure_ascii=False)
        except:
            raise 

if __name__ == "__main__":

    parse = argparse.ArgumentParser()
    parse.add_argument('--from-dir', help='从目录中读取需要汇总的文件', required=True)
    parse.add_argument('--output-dir', help='汇总后文件的输出目录，缺省值为当前目录')
    parse.add_argument('--label', help='定义json.metadata.flags的值(标签)，缺省值为None')
    args = parse.parse_args()

    if not os.path.isdir(Path(args.from_dir)):
        raise FileNotFoundError(f'No such file or directory ({Path(args.from_dir)})')

    if args.output_dir:
        if not os.path.isdir(Path(args.output_dir)):
            raise FileNotFoundError(f'No such file or directory ({Path(args.output_dir)})')
        summary = Summar(
            list(map(lambda name: Path(os.path.join(args.from_dir, name)), os.listdir(Path(args.from_dir)))),
            save_dir=Path(args.output_dir)
        )
    else:
        summary = Summary(
            list(map(lambda name: Path(os.path.join(args.from_dir, name)), os.listdir(Path(args.from_dir))))
        )
    
    d = summary.load_data()
    if args.label:
        summary.save_as_json(flags=args.label)
    else:
        summary.save_as_json()