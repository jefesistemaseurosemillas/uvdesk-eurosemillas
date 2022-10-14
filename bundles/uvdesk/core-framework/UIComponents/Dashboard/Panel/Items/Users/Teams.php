<?php

namespace Webkul\UVDesk\CoreFrameworkBundle\UIComponents\Dashboard\Panel\Items\Users;

use Webkul\UVDesk\CoreFrameworkBundle\Dashboard\Segments\PanelSidebarItemInterface;
use Webkul\UVDesk\CoreFrameworkBundle\UIComponents\Dashboard\Panel\Sidebars\Users;

class Teams implements PanelSidebarItemInterface
{
    public static function getTitle() : string
    {
        return "Teams";
    }

    public static function getRouteName() : string
    {
        return 'helpdesk_member_support_team_collection';
    }

    public static function getSupportedRoutes() : array
    {
        return [
            'helpdesk_member_create_support_team',
            'helpdesk_member_update_support_team',
            'helpdesk_member_support_team_collection', 
        ];
    }

    public static function getRoles() : array
    {
        return ['ROLE_AGENT_MANAGE_SUB_GROUP'];
    }

    public static function getSidebarReferenceId() : string
    {
        return Users::class;
    }
}
