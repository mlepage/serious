Serious
=======

Serious is a suite of serialization utilities for Lua and XML, written by Marc Lepage.

You can parse XML into a simple object model, write it out, then read it back in, all as Lua.


Simple Object Model
-------------------

The simple object model has these properties:

- elem[0] is the name
- elem[-1] is any non-whitespace text
- elem.name is an attribute value
- elem[n] is the nth child element

Element text and attributes can be strings or numbers. Attribute order is undefined.

The following XML:

    <empty/>
    <single_att_str str='leet'/>
    <single_att_num num='1337'/>
    <multi_att str='leet' num='1337'/>
    <Mixed_Case Att_Str='leet' Att_Num='1337'/>
    <single_text_str>leet</single_text_str>
    <single_text_num>1337</single_text_num>
    <single_child><child/></single_child>
    <multi_child><child1/><child2/></multi_child>
    <multi_text>foo<child/>bar</multi_text>
    <multi_text>foo<child1/>bar<child2/>baz</multi_text>
    <multi_text>abc<child1/>123<child2/>def</multi_text>
    <complex>
        <child1/>
        <child2>xyzzy</child2>
        <child3>42</child3>
        <list>
            <type1 x='1' y='2' enabled='false'/>
            <type2 x='3' y='4' enabled='true'/>
            <type3 x='5' y='6' enabled='unknown'/>
        </list>
        <child4 enabled='unknown'/>
        <child5 amount='3.14'/>
    </complex>

Becomes the following Lua:

    {
        { [0]='empty' },
        { [0]='single_att_str', str='leet' },
        { [0]='single_att_num', num=1337 },
        { [0]='multi_att', str='leet', num=1337 },
        { [0]='Mixed_Case', Att_Str='leet', Att_Num=1337 },
        { [0]='single_text_str', [-1]='leet' },
        { [0]='single_text_num', [-1]=1337 },
        { [0]='single_child',
            { [0]='child' }
        },
        { [0]='multi_child',
            { [0]='child1' },
            { [0]='child2' }
        },
        { [0]='multi_text', [-1]='foobar',
            { [0]='child' }
        },
        { [0]='multi_text', [-1]='foobarbaz',
            { [0]='child1' },
            { [0]='child2' }
        },
        { [0]='multi_text', [-1]='abc123def',
            { [0]='child1' },
            { [0]='child2' }
        },
        { [0]='complex',
            { [0]='child1' },
            { [0]='child2', [-1]='xyzzy' },
            { [0]='child3', [-1]=42 },
            { [0]='list',
                { [0]='type1', x=1, enabled='false', y=2 },
                { [0]='type2', x=3, enabled='true', y=4 },
                { [0]='type3', x=5, enabled='unknown', y=6 }
            },
            { [0]='child4', enabled='unknown' },
            { [0]='child5', amount=3.14 }
        }
    }


Usage
-----

Parse XML into simple object model:

    root = parseXML(str)

Loop over an element's children:

    for i = 1, #root do
        local child = root[i]
        print(child[0])
    end

Get the names of some children:

    child2, child3 = root[2], root[3]
    print(child2[0], child3[0])

Get some attributes by name:

    print(root[4].str, root[4].num)

Loop over an element's attributes:

    for k, v in pairs(root[4]) do
        if type(k) == 'string' then
            print(k, v)
        end
    end

Get the text of some children:

    child7, child10 = root[7], root[10]
    print(child7[-1], child10[-1])

Write out the object model:

    export(io.stdout, root)


License
-------

Serious is licensed under the [MIT License][1].

[1]: http://en.wikipedia.org/wiki/MIT_License
