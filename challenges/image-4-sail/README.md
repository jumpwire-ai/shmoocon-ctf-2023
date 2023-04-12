# image 4 sail

The flag was added in a docker layer, then removed in the next layer. Using dive shows what all of the layers did, along with the layer ID. I couldn't figure out how to copy a file with dive, but once the image ID is identified it can be untarred:

``` shell
dive public.ecr.aws/extragood/image-4-sail
# find the layer id of 88b4ca73f533d0c54df25f335c89ff9f36923884246a8cc4d3c0aa0a017473d4 where
# the flag was added

docker save public.ecr.aws/extragood/image-4-sail > image.tar
tar xf image.tar
cd 88b4ca73f533d0c54df25f335c89ff9f36923884246a8cc4d3c0aa0a017473d4/
tar xf layer.tar
cat flag
```
