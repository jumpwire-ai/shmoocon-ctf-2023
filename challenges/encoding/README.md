# encoding

Multiple levels of encoding:

- raw flag
- reversed
- base85
- base64
- binary

CyberChef formula for creating the text:
https://gchq.github.io/CyberChef/#recipe=Reverse('Character')To_Base85('!-u',true)To_Base64('A-Za-z0-9%2B/%3D')To_Binary('None',8)

and for solving:

https://gchq.github.io/CyberChef/#recipe=From_Binary('None',8)From_Base64('A-Za-z0-9%2B/%3D',true,false)From_Base85('!-u',true,'z')Reverse('Character')
