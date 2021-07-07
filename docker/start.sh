#!/usr/bin/env python3

# If not stated otherwise in this file or this component's license file the
# following copyright and licenses apply:
#
# Copyright 2020 Consult Red
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import tarfile
import tempfile
import os


def main():
    parser = argparse.ArgumentParser(
        prog='start', description='BundleGen runner')
    parser.add_argument('image', help="Path to the .tar image generated by the SDK")
    parser.add_argument('platform', help="Path to the platform template JSON file")

    args = parser.parse_args()

    if not os.path.exists(args.image):
        print("Could not find file", args.image)
        return

    image_name = os.path.basename(args.image).replace('.tar', '')

    if not os.path.exists(args.platform):
        print("Could not find file", args.platform)
        return

    platform_template_dir = os.path.dirname(args.platform)
    platform_template_name = os.path.basename(args.platform).replace('.json', '')

    os.environ['TEMPLATE_DIR'] = platform_template_dir

    # Extract the .tar to a temp directory
    img_temp_path = tempfile.mkdtemp()

    os.environ['EXTRACTED_IMG_DIR'] = img_temp_path

    with tarfile.open(args.image) as tar:
        tar.extractall(img_temp_path)

    os.system('docker-compose run bundlegen generate -y --platform {} oci:/image:latest /bundles/{}'.format(
        platform_template_name, image_name
    ))

    print("Done!")
    print("Download the OCI bundle at http://localhost:8080/{}.tar.gz".format(image_name))

if __name__ == "__main__":
    main()
