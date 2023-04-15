#include "StdAfx.h"
#include "Component.h"

plana::entitys::Entity::~Entity()
{
    destroy();
}

void plana::entitys::Entity::destroy()
{
    for (auto i : type_holders_)
    {
        delete i.second;
    }
    type_holders_.clear();
}

namespace plana {
namespace entitys {
namespace pr {
Entity instance;
}

void Init()
{

}

plana::entitys::Entity& GetEntity()
{
    return pr::instance;
}

void Uinit()
{
    pr::instance.destroy();
}

}
}